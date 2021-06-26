#!/usr/bin/env bash

# -e: Exit on first failure
# -E (-o errtrace): Ensures that ERR traps get inherited by functions and subshells.
# -u (-o nounset): Treats unset variables as errors.
# -o pipefail: This option will propagate intermediate errors when using pipes.
set -Eeo pipefail
# set -ex

script_name="$(basename -- "$0")"
script_dir="$(dirname "$0")"

trap err_exit ERR

err_exit () {
	echo "echo ⚠️ Something went wrong! Tidying up..."
	down
	exit 1
}

help_text()
{
    echo ""
    echo "Helper script to run and manage the scripts invoked by the CI pipeline."
    echo ""
    echo "⚠️  This must be run from the root of the repository."
    echo ""
    echo "Usage:        $script_dir/$script_name COMMAND"
    echo ""
    echo "Available Commands:"
    echo "  build         🔨  Build ci and webapp docker images"
    echo "  unit_tests    🕵  Run unit tests"
    echo "  lint          ✨  Run pre-commit hooks (linting)"
    echo "  up            🟢  Start webapp container"
    echo "  down          🔴  Stop webapp container"
    echo "  push_images   🐳  Publish images to Dockerhub"
	echo "  helm_build    📦  Run helm lint, template, and package"
    echo "  run           🚀  Run all CI steps"
}

check_required_env_variables()
{
	var_not_set() {
		echo "❌ Environment variable not set: $1" 1>&2
		exit 1
	}
    if [[ ! $DOCKER_PASSWORD ]]; then
        var_not_setf "DOCKER_PASSWORD"
    fi
}

set_common_env_variables()
{
	export DOCKER_CLI_EXPERIMENTAL=enabled
	export CONTAINER_REGISTRY=gbournique.azurecr.io
	export DOCKER_USER=gbournique
	export CI_IMAGE_REPOSITORY=${CONTAINER_REGISTRY}/${DOCKER_USER}/aks_demo_cicd
	export WEBAPP_IMAGE_REPOSITORY=${CONTAINER_REGISTRY}/${DOCKER_USER}/aks_demo
	export WEBAPP_CONTAINER_NAME=webapp
	export DEPLOYMENT_DIR="./deployment/"

	check_required_env_variables
}

docker-ci() {
	docker network create global-network 2>/dev/null || true; \
	docker run \
		-it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(pwd):/root/cicd/ \
		--network global-network \
		${CI_IMAGE_REPOSITORY}:$(ci_image_tag) bash -c "$*"
}

ci_image_tag() {
	echo $(cat ./build_steps/cicd.Dockerfile environment.yml poetry.lock | cksum | cut -c -8)
}

build_ci_image() {
	printf "Building ci docker image ${CI_IMAGE_REPOSITORY}:$(ci_image_tag)...\n"
	if docker manifest inspect ${CI_IMAGE_REPOSITORY}:$(ci_image_tag) >/dev/null 2>&1; then
		echo Docker image ${CI_IMAGE_REPOSITORY}:$(ci_image_tag) already exists on Dockerhub! Not building.
		docker pull ${CI_IMAGE_REPOSITORY}:$(ci_image_tag)
	else \
		docker build -t ${CI_IMAGE_REPOSITORY}:$(ci_image_tag) -f ./build_steps/cicd.Dockerfile .
	fi
}

webapp_image_tag() {
	WEBAPP_DEPENDENCIES_FILES=$(echo $(find ./aks_demo -type f -not -name "*.pyc" -not -name "*.log") \
								"./deployment/Dockerfile" "environment.yml" "poetry.lock")
	CKSUM=$(cat ${WEBAPP_DEPENDENCIES_FILES} | cksum | cut -c -8)
	PROJECT_VERSION=$(awk '/^version/' pyproject.toml | sed 's/[^0-9\.]//g')
	echo ${PROJECT_VERSION}-${CKSUM}
}

build_webapp_image() {
	printf "Building webapp docker image ${WEBAPP_IMAGE_REPOSITORY}:$(webapp_image_tag)...\n"
	if docker manifest inspect ${WEBAPP_IMAGE_REPOSITORY}:$(webapp_image_tag) >/dev/null 2>&1; then
		echo Docker image ${WEBAPP_IMAGE_REPOSITORY}:$(webapp_image_tag) already exists on Dockerhub! Not building.
		docker pull ${WEBAPP_IMAGE_REPOSITORY}:$(webapp_image_tag)
	else \
		rm -rf dist
		docker-ci poetry build
		docker build -t ${WEBAPP_IMAGE_REPOSITORY}:$(webapp_image_tag) -f ./deployment/Dockerfile .
	fi
	docker tag ${WEBAPP_IMAGE_REPOSITORY}:$(webapp_image_tag) ${WEBAPP_IMAGE_REPOSITORY}:latest
}

unit_tests()
{
	docker-ci "pytest ."
}

lint()
{
	docker-ci pre-commit run --all-files --show-diff-on-failure
}

up()
{
	docker-ci "cd ${DEPLOYMENT_DIR}; docker-compose up -d" || true
}

down()
{
	docker-ci "cd ${DEPLOYMENT_DIR}; docker-compose down" || true
}

publish_image()
{
	echo ${DOCKER_PASSWORD} | docker login ${CONTAINER_REGISTRY} --username ${DOCKER_USER} --password-stdin 2>&1
	printf "Publishing $1:$2...\n"
	docker push $1:$2
	docker tag $1:$2 $1:latest
	docker push $1:latest
}

helm_build()
{
	docker-ci helm lint deployment/kubernetes/aks-demo
	docker-ci helm template dev deployment/kubernetes/aks-demo --output-dir deployment/kubernetes/packaged/ --dry-run
	docker-ci helm package deployment/kubernetes/aks-demo -d deployment/kubernetes/bin/
	# docker-ci helm publish ...
}

# Script starting point
if [[ -n $1 ]]; then
	case "$1" in
		build)
			printf "🔨 Building ci and webapp docker images...\n"
			set_common_env_variables
			build_ci_image
			build_webapp_image
			exit 0
			;;
		up)
			printf "🐳 Starting webapp container...\n"
			set_common_env_variables
			up
			exit 0
			;;
		unit_tests)
			printf "🔎🕵 Running unit tests...\n"
			set_common_env_variables
			unit_tests
			exit 0
			;;
		lint)
			printf "🚨✨ Running pre-commit hooks (linting)...\n"
			set_common_env_variables
			lint
			exit 0
			;;
		down)
			printf "🔴  Stop webapp container...\n"
			set_common_env_variables
			down
			exit 0
			;;
		push_images)
			printf "🐳 Publishing images to Dockerhub...\n"
			set_common_env_variables
			publish_image ${WEBAPP_IMAGE_REPOSITORY} $(webapp_image_tag)
			publish_image ${CI_IMAGE_REPOSITORY} $(ci_image_tag)
			exit 0
			;;
		helm_build)
			printf "📦  Run helm lint, template, and package...\n"
			set_common_env_variables
			helm_build
			exit 0
			;;
		run)
			printf "🚀 Running CI pipeline steps (for local troubleshooting)...\n"
			set_common_env_variables
			build_ci_image
			build_webapp_image
			unit_tests
			lint
			up
			down
			publish_image ${WEBAPP_IMAGE_REPOSITORY} $(webapp_image_tag)
			publish_image ${CI_IMAGE_REPOSITORY} $(ci_image_tag)
			helm_build
			exit 0
			;;
		*)
			echo "¯\\_(ツ)_/¯ What do you mean \"$1\"?"
			help_text
			exit 1
			;;
	esac
else
	help_text
	exit 1
fi

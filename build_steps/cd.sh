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
	exit 1
}

help_text()
{
    echo ""
    echo "Helper script to run and manage the scripts invoked by the CD pipeline."
    echo ""
    echo "⚠️  This must be run from the root of the repository."
    echo ""
    echo "Usage:        $script_dir/$script_name <COMMAND>"
    echo ""
    echo "Available Commands:"
    echo "  tf_provision        🚀 Run Terraform to provision an AKS cluster"
	echo "  helm_install        🚚 Run Helm install to deploy application to the cluster"
    echo "  load_testing        📈 Run load testing on deployed web application"
    echo "  tf_destroy          💥 Run Terraform to destroy the AKS cluster"
}

set_common_env_variables()
{
	# Docker (experimental cli to use docker manifest)
	export CONTAINER_REGISTRY=gbournique.azurecr.io
	export DOCKER_USER=gbournique
	export CD_IMAGE=${CONTAINER_REGISTRY}/${DOCKER_USER}/aks_demo_cicd:latest

	# Load testing
	# export WEBSERVER_URL=https://${CFN_STACK_NAME}.bournique.fr
	# export USERS=200
	# export SPAWN_RATE_PS=50
	# export RUN_TIME=30s
}

# To run command within a container which has all required packages installed
docker-cd() {
	docker run \
		-it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(pwd):/root/cicd/ \
		${CD_IMAGE} bash -c "$*"
}


# Script starting point
if [[ -n $1 ]]; then
	set_common_env_variables
	case "$1" in
		tf_provision)
			printf "🚀  Run Terraform to provision an AKS cluster...\n"
			echo "👷‍♂️ Work in progress"
			exit 0
			;;
		helm_install)
			printf "🚚  Run Helm install to deploy application to the cluster...\n"
			echo "👷‍♂️ Work in progress"
			exit 0
			;;
		load_testing)
			printf "📈 	Run load testing on deployed web application...\n"
			echo "👷‍♂️ Work in progress"
			exit 0
			;;
		tf_destroy)
			printf "💥  Run Terraform to destroy the AKS cluster...\n"
			echo "👷‍♂️ Work in progress"
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

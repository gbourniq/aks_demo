#!/usr/bin/env bash

# -e: Exit on first failure
# -E (-o errtrace): Ensures that ERR traps get inherited by functions and subshells.
# -u (-o nounset): Treats unset variables as errors.
# -o pipefail: This option will propagate intermediate errors when using pipes.
# set -Eeo pipefail
set -ex

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
    echo "  helm_install        🚚  Install Helm chart to AWS cluster"
    echo "  helm_uninstall      💥  Uninstall Helm chart application"
}

set_common_env_variables()
{
	# Docker (experimental cli to use docker manifest)
	export CONTAINER_REGISTRY=gbournique.azurecr.io
	export DOCKER_USER=gbournique
	export CD_IMAGE=${CONTAINER_REGISTRY}/${DOCKER_USER}/aks_demo_cicd:27792099

	# Azure credentials
	# https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal?tabs=azure-cli
	# https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli
	export APP_ID="c61dba0d-e872-4c8d-92a4-2726ff29f9a0"
	export TENANT_ID="fd156fba-d621-4e30-a7c6-1984f55c021b"
	export RG_NAME="aks-demo-rg"
	export CLUSTER_NAME="aks-demo-cluster"
	export CLUSTER_NS="aks-demo-playground"
	export IMAGE_TAG=$(webapp_image_tag)
	# export SERVICE_ACCOUNT_PWD= # set as a local environment variable

}

# To run command within a container which has all required packages installed
docker-cd() {
	docker run \
		-it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(pwd):/root/cicd/ \
		-v ~/.kube:/root/.kube/ \
		-v ~/.azure:/root/.azure/ \
		${CD_IMAGE} bash -c "$*"
}

webapp_image_tag() {
	WEBAPP_DEPENDENCIES_FILES=$(echo $(find ./aks_demo -type f -not -name "*.pyc" -not -name "*.log") "./deployment/Dockerfile" "environment.yml" "poetry.lock")
	CKSUM=$(cat ${WEBAPP_DEPENDENCIES_FILES} | cksum | cut -c -8)
	PROJECT_VERSION=$(awk '/^version/' pyproject.toml | sed 's/[^0-9\.]//g')
	echo ${PROJECT_VERSION}-${CKSUM}
}

helm_install()
{
	docker-cd "az login --service-principal --username $APP_ID --password $SERVICE_ACCOUNT_PWD --tenant $TENANT_ID && az aks get-credentials --resource-group $RG_NAME --name $CLUSTER_NAME"
	docker-cd "az aks get-credentials --resource-group $RG_NAME --name $CLUSTER_NAME"
	docker-cd "helm upgrade dev deployment/kubernetes/aks-demo --set Values.global.image.tag=$IMAGE_TAG --install --wait -n $CLUSTER_NS"
}

helm_uninstall()
{
	docker-cd "az login --service-principal --username $APP_ID --password $SERVICE_ACCOUNT_PWD --tenant $TENANT_ID && az aks get-credentials --resource-group $RG_NAME --name $CLUSTER_NAME"
	docker-cd "az aks get-credentials --resource-group $RG_NAME --name $CLUSTER_NAME"
	docker-cd "helm uninstall dev -n $CLUSTER_NS"
}

# Script starting point
if [[ -n $1 ]]; then
	set_common_env_variables
	case "$1" in
		helm_install)
			printf "🚚  Install Helm chart to AWS cluster...\n"
			helm_install
			exit 0
			;;
		helm_uninstall)
			printf "💥  Uninstall Helm chart application...\n"
			helm_uninstall
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

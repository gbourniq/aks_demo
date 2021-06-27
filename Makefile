# Oneshell means I can run multiple lines in a recipe in the same shell, so I don't have to
# chain commands together with semicolon
.ONESHELL:

# Set shell
SHELL=/bin/bash

# Environment variables
IMAGE_NAME=gbournique.azurecr.io/gbournique/aks_demo:latest
CONDA_ENV_NAME=aks-demo
CONDA_CREATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda env create
CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate
HELM_RELEASE=dev
HELM_CHART_DIR=deployment/kubernetes/aks-demo
HELM_PACKAGE_DIR=deployment/kubernetes/bin/
K8S_NAMESPACE=aks-demo-playground

### environment ###
.PHONY: env env-update

env:
	@ $(CONDA_CREATE) -f environment.yml -n $(CONDA_ENV_NAME)
	@ ($(CONDA_ACTIVATE) $(CONDA_ENV_NAME); poetry install)

env-update:
	@ conda env update -f environment.yml -n $(CONDA_ENV_NAME)
	@ ($(CONDA_ACTIVATE) $(CONDA_ENV_NAME); poetry update)

### githooks ###
.PHONY: pre-commit

pre-commit:
	pre-commit install -t pre-commit -t commit-msg

### Development ###
.PHONY: lint run test

lint:
	pre-commit run --all-files

test:
	pytest .

cov:
	open htmlcov/index.html

run:
	python aks_demo/run.py

### Docker deployment ###
.PHONY: build up down

build:
	docker build -t ${IMAGE_NAME} -f deployment/Dockerfile .

up:
	cd deployment && docker-compose up -d
	
down:
	cd deployment && docker-compose down

### Kubernetes deployment ###
.PHONY: yaml-lint helm-lint helm-template helm-package helm-install helm-publish

yaml-lint:
	yamllint . -d relaxed --no-warnings

helm-lint:
	helm lint ${HELM_CHART_DIR}

helm-template:
	helm template ${HELM_RELEASE} ${HELM_CHART_DIR} --output-dir ${HELM_PACKAGE_DIR} --dry-run

helm-package:
	helm package ${HELM_CHART_DIR} -d ${HELM_PACKAGE_DIR}

helm-install:
	helm upgrade ${HELM_RELEASE} ${HELM_CHART_DIR} --install --wait -n ${K8S_NAMESPACE}

helm-uninstall:
	helm uninstall ${HELM_RELEASE} -n ${K8S_NAMESPACE}

helm-tests:
	helm test ${HELM_RELEASE} -n ${K8S_NAMESPACE}

helm-publish:
	@ echo "Work in progress"

ingress-controller-install:
	./deployment/kubernetes/ingress-nginx/installer.sh

ingress-controller-uninstall:
	./deployment/kubernetes/ingress-nginx/uninstaller.sh
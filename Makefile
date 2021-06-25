# Oneshell means I can run multiple lines in a recipe in the same shell, so I don't have to
# chain commands together with semicolon
.ONESHELL:

# Set shell
SHELL=/bin/bash

# Environment variables
IMAGE_REPOSITORY=gbournique/aks_demo:latest
CONDA_ENV_NAME=aks-demo
CONDA_CREATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda env create
CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate
HELM_RELEASE=dev
HELM_CHART_DIR=deployment/kubernetes/aks-demo
HELM_TEMPLATES_DIR=deployment/kubernetes/packaged/
HELM_PACKAGE_DIR=deployment/kubernetes/bin/

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
	@ pre-commit install -t pre-commit -t commit-msg

### Development ###
.PHONY: lint run test

lint:
	@ pre-commit run --all-files

test:
	@ pytest .

cov:
	@ open htmlcov/index.html

run:
	@ python aks_demo/run.py

### Docker deployment ###
.PHONY: build up down

build:
	@ docker build -t ${IMAGE_REPOSITORY} -f deployment/Dockerfile .

up:
	@ cd deployment && docker-compose up -d
	
down:
	@ cd deployment && docker-compose down

### Kubernetes deployment ###
.PHONY: helm-lint helm-package helm-install

helm-lint:
	@ helm lint ${HELM_CHART_DIR}

helm-template:
	@ rm -rf ${HELM_TEMPLATES_DIR}
	@ helm template ${HELM_RELEASE} ${HELM_CHART_DIR} --output-dir ${HELM_TEMPLATES_DIR} --dry-run

helm-package:
	@ helm package ${HELM_CHART_DIR} -d ${HELM_PACKAGE_DIR}

helm-install:
	@ helm upgrade ${HELM_RELEASE} ${HELM_CHART_DIR} --install --wait

helm-tests:
	@ helm test ${HELM_RELEASE}
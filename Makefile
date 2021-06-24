# Oneshell means I can run multiple lines in a recipe in the same shell, so I don't have to
# chain commands together with semicolon
.ONESHELL:

# Environment variables
IMAGE_REPOSITORY=aks_demo:latest
CONDA_ENV_NAME=aks-demo
CONDA_CREATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda env create
CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate

# Set shell
SHELL=/bin/bash

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

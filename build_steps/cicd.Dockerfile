ARG CONDA_VERSION=4.9.2
FROM continuumio/miniconda3:${CONDA_VERSION}

ARG POETRY_HOME="/opt/poetry"
ARG WORKDIR=/root/cicd
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    # install poetry to this location
    POETRY_HOME=${POETRY_HOME} \
    # prevent poetry from creating a virtual environment in the project's root
    POETRY_VIRTUALENVS_IN_PROJECT=false \
    # prepend poetry and venv to path
    PATH="${POETRY_HOME}/bin:$PATH" \
    # for docker inspect manifest
    DOCKER_CLI_EXPERIMENTAL=enabled \
    PYTHONPATH=${WORKDIR}

RUN apt-get update \
    && apt-get install --no-install-recommends -yq \
    # jq: for parsing json responses
    # vim: for any troubleshooting
    # curl, wget and unzip: to install software and packages
    # build-essential: for building python deps
    # docker.io: for running docker commands
    # gcc libpq-dev python3-dev: psycopg2 source dependencies
    jq curl vim wget unzip build-essential docker.io gcc libpq-dev python3-dev \
    && rm -rf /var/lib/apt/lists/*

ARG DOCKER_COMPOSE_VERSION=1.27.4
ARG POETRY_VERSION=1.0.10
RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py -o ~/get-poetry.py \
    # Install and configure poetry
    && python ~/get-poetry.py --version ${POETRY_VERSION} -y \
    && rm ~/get-poetry.py \
    # Install docker-compose
    && curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    # Initialise conda shell
    && echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    # Upgrade pip
    && pip install --upgrade pip

WORKDIR ${WORKDIR}

COPY environment.yml poetry.lock pyproject.toml ./

# Install poetry dependencies within conda environment
RUN conda env create -f environment.yml -n aks-demo
SHELL ["conda", "run", "-n", "aks-demo", "/bin/bash", "-c"]
RUN poetry install

ENV KUBECTL_VERSION="v1.20.5"
ENV HELM_VERSION="v3.5.2"

# Install kubectl
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Install helm
RUN wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Activate conda environment for any runtime commands
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "aks-demo"]

CMD ["tail", "-f", "/dev/null"]
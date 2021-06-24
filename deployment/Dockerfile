FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8

ARG POETRY_VERSION="1.0.10"
ARG USERNAME="aksdemouser"
ENV REPO_HOME="/home/${USERNAME}" \
    PYTHONPATH="/home/${USERNAME}" \
    USERNAME=${USERNAME}

# Add non-root user
RUN adduser --disabled-password --gecos "" ${USERNAME}

# Set working directory
WORKDIR ${REPO_HOME}

# Copy dependencies files
COPY poetry.lock pyproject.toml ./

# Install poetry and app dependencies
RUN pip install "poetry==${POETRY_VERSION}" \
    && poetry config virtualenvs.create false \
    && poetry install --no-dev --no-interaction --no-ansi \
    && rm poetry.lock pyproject.toml

# Add project source code to /home/aksdemouser
COPY ./aks_demo ./aks_demo/

# Change ownership of /home/portfolio to portfoliouser
RUN chown -R ${USERNAME}:${USERNAME} ${REPO_HOME}

# TODO: Run container as non-root
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8

ARG USERNAME="aksdemouser"
ENV REPO_HOME="/home/${USERNAME}" \
    PYTHONPATH="/home/${USERNAME}" \
    USERNAME=${USERNAME}

# Set working directory
WORKDIR ${REPO_HOME}

# Install poetry
ENV POETRY_VERSION=1.1.4
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python
ENV PATH /root/.poetry/bin:$PATH

# Copy package dependencies files
COPY poetry.lock pyproject.toml ./

# Install app dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-interaction --no-ansi \
    && rm poetry.lock pyproject.toml

# Add application code to /home/aksdemouser/aks_demo/
COPY ./aks_demo ./aks_demo/

# Add non-root user
RUN adduser --disabled-password --gecos "" ${USERNAME} \
    && chown -R ${USERNAME}:${USERNAME} ${REPO_HOME}

# Run container as non-root
USER ${USERNAME}
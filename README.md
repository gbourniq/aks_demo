# AKS Demo

## Installation for local development

#### Prerequisites
- Clone this repo [aks_demo](ssh://git@github.com:gbourniq/aks-demo.git) and cd into it
- Install [Miniconda](https://docs.conda.io/en/latest/miniconda.html)
- Install [Poetry](https://github.com/sdispater/poetry) - you will need version 1.0.0 or greater

#### Create conda environment and install dependencies with poetry

```bash
conda env create
conda activate aks-demo
poetry install
```

#### Set up pre-commit for githooks
```bash
make pre-commit
```

#### Run webserver locally
run 
```python
python aks_demo/run.py
```

Visit `localhost:5000`


## Remote server deployment (docker-compose)

#### Prerequisite
The instance must have the following software installed:
- `docker`
- `docker-compose`
- `make` (optional)

... Helm instructions

8. Visit `http://172.31.15.249:5700`

9. Stop the containerised webserver
```bash
make down
```

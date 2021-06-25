"""Main configuration parameters for FastAPI"""

from os import getenv
from pathlib import Path
from typing import List

from starlette.config import Config
from starlette.datastructures import CommaSeparatedStrings, Secret

# Paths
aks_demo_DIR = Path(__file__).resolve().parent
ENV_PATH = aks_demo_DIR / ".env"
config = Config(env_file=ENV_PATH)


class FastApiConfig:
    """FastAPI settings"""

    API_PREFIX: str = config("API_PREFIX")
    ALLOWED_HOSTS: List[str] = config("ALLOWED_HOSTS", cast=CommaSeparatedStrings)
    DEBUG: bool = config("DEBUG", cast=bool)
    PROJECT_DESCRIPTION: str = f"{config('PROJECT_DESCRIPTION')} - Running on {getenv('HOSTNAME')}"
    PROJECT_NAME: str = config("PROJECT_NAME")
    ROOT_PATH: str = config("ROOT_PATH", default="/")
    VERSION: str = config("VERSION")


class UvicornConfig:
    """
    Uvicorn will first look for environment variables of the same name,
    or use the default values defined in this class.
    """

    DEBUG: bool = False
    FASTAPI_APP: str = config("FASTAPI_APP")
    RELOAD: bool = config("RELOAD", cast=bool)
    WEBSERVER_HOST: str = config("WEBSERVER_HOST")
    WEBSERVER_PORT: int = config("WEBSERVER_PORT", cast=int)
    WORKERS_COUNT: int = config("WORKERS_COUNT", cast=int)


SECRET_KEY_HEADER: Secret = getenv(
    "SECRET_KEY_HEADER", config("SECRET_KEY_HEADER", cast=Secret)
)

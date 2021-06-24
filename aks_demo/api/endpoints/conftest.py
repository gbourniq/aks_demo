"""This file defines pytest fixtures"""

from typing import Generator

import pytest
from fastapi.testclient import TestClient
from starlette.datastructures import Headers

from aks_demo.main import app


@pytest.fixture(scope="module")
def mock_client() -> Generator[TestClient, None, None]:
    """
    Returns a fastapi test client or the request module
    to test against a running server
    """
    with TestClient(app) as client:
        yield client


@pytest.fixture(scope="module")
def api_prefix_v1() -> str:
    """Returns a the api prefix for v1 endpoints"""
    return "api/v1"


@pytest.fixture(scope="module")
def valid_mock_secret_key() -> Headers:
    """Retuns the valid mock x-secret-key headers"""
    return Headers({"api-key": "secret"})


@pytest.fixture(scope="module")
def invalid_mock_secret_key() -> Headers:
    """Retuns the valid mock x-secret-key headers"""
    return Headers({"api-key": "invalid_secret"})

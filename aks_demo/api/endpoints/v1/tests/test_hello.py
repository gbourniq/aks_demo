"""This module defines tests for the api/v1/hello endpoint"""
from http import HTTPStatus

from fastapi.testclient import TestClient

ENDPOINT = "hello/"


def test_hello_world(api_prefix_v1: str, mock_client: TestClient):
    """Asserts the hello get endpoint returns Hello World"""
    # Given: The hello world endpoint
    endpoint = f"{api_prefix_v1}/{ENDPOINT}"

    # When: The endpoint is hit with a GET request
    response = mock_client.get(endpoint)

    # Then: The response status code is 200 and response body {"message": "Hello World"}
    assert response.status_code == HTTPStatus.OK.value
    assert response.json()["message"] == "Hello World! v2"

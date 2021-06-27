"""This module defines unit tests for the api/v1/prediction endpoint"""

import json
from http import HTTPStatus

import pytest
from fastapi.testclient import TestClient
from starlette.datastructures import Headers

from aks_demo.models.input import TriggerEvent
from aks_demo.models.output import PredictionResponse

ENDPOINT = "prediction/"


@pytest.mark.parametrize(
    argnames="event_id, input_data, expected_prediction",
    argvalues=[
        (1, "data1", "predicted data1"),
        (2, "data2", "predicted data2"),
        (3, "data3", "predicted data3"),
    ],
)
def test_prediction(
    api_prefix_v1: str,
    mock_client: TestClient,
    valid_mock_secret_key: Headers,
    event_id: int,
    input_data: str,
    expected_prediction: str,
):
    """Asserts the prediction endpoint returns expected mock predictions"""

    # Given: A url with path parameters and query parameter
    endpoint = f"{api_prefix_v1}/{ENDPOINT}/?generate_report=true"

    # Given: A payload with input data to process
    payload = {"event_id": event_id, "payload": {"data": input_data}}

    # When: POST request with a valid payload and valid secret key header
    response = mock_client.post(endpoint, json=payload, headers=valid_mock_secret_key)

    # Then: Returned status code is 200
    assert response.status_code == HTTPStatus.OK.value

    # Then: The expected response is returned
    expected = dict(
        event_id=event_id,
        input_value=input_data,
        predicted_value=expected_prediction,
        report_generated=True,
    )
    assert response.json() == expected

    # Then: Expected Pydantic model for both input payload and response
    TriggerEvent.parse_raw(json.dumps(payload))
    PredictionResponse.parse_raw(json.dumps(response.json()))


def test_invalid_api_key_header(
    api_prefix_v1: str, mock_client: TestClient, invalid_mock_secret_key: Headers,
):
    """
    Asserts the expected response is returned to the client when
    an invalid API key header is provided
    """

    # Given: A url with path parameters and query parameter
    endpoint = f"{api_prefix_v1}/{ENDPOINT}"

    # Given: A payload with input data to process
    payload = {"event_id": 1, "payload": {"data": "mock input"}}

    # When: POST request with an invalid secret key header
    response = mock_client.post(endpoint, json=payload, headers=invalid_mock_secret_key)

    # Then: The status code is 418 and the client is informed of the invalid key
    assert response.status_code == 418
    assert response.json()["message"] == "InvalidSecretKeyError: X-Api-Key invalid"

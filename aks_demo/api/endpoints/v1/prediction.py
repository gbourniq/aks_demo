"""
This module defines operations for the following /api/v1/base endpoint
"""
import logging
import traceback
from typing import Optional

from fastapi import APIRouter, BackgroundTasks, status

from aks_demo.models.input import TriggerEvent
from aks_demo.models.output import PredictionResponse

logger = logging.getLogger(__name__)

router = APIRouter()


def generate_report_task(event: TriggerEvent):
    """Background process to generate report / send notifications"""
    try:
        logger.info(
            f"Generating report for {event.payload.data} with a background task"
        )
    # pylint: disable=broad-except
    except Exception as excpt:
        logger.error(
            "The following error occurred: %s\n%s", repr(excpt), traceback.format_exc()
        )


@router.post("/", status_code=status.HTTP_200_OK, response_model=PredictionResponse)
async def prediction(
    event: TriggerEvent,
    background_tasks: BackgroundTasks,
    generate_report: Optional[bool] = None,
):
    """This endpoint receives events to process.

    Args:
    - event (TriggerEvent): Trigger event including the payload data to process
    - background_tasks (BackgroundTasks): background_tasks object to perform
            operations after the response is returned to the client.
    - generate_report (Optional[bool]): Query parameter to generate a report in a
            background task. Defaults to None.

    Returns:
    - Response (PredictionResponse): PredictionResponse response model object
    """
    # Mock prediction from input
    mock_prediction = f"predicted {event.payload.data}"

    if generate_report:
        background_tasks.add_task(generate_report_task, event)

    return dict(
        event_id=event.event_id,
        input_value=event.payload.data,
        predicted_value=mock_prediction,
        report_generated=bool(generate_report),
    )

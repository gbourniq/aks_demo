"""This module defines pydantic models for incoming HTTP body requests"""
from pydantic import BaseModel, Field


class PayLoad(BaseModel):
    """
    Expected payload from the event
    """

    data: str = Field(..., title="Mock data to process")


class TriggerEvent(BaseModel):
    """
    Expected event schema to be processed
    """

    event_id: int = Field(..., title="Event ID")
    payload: PayLoad = Field(..., title="Payload")

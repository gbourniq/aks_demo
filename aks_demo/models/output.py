"""This module defines pydantic models for returned responses"""
from pydantic import BaseModel, Field


class PredictionResponse(BaseModel):
    """
    Output model to be returned upon a successful prediction
    """

    event_id: int = Field(..., title="Event ID")
    input_value: str = Field(..., title="Input value")
    predicted_value: str = Field(..., title="Predicted value")
    report_generated: bool = Field(
        ..., title="Indicates whether a report was generated in the background"
    )

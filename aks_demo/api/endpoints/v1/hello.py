"""
This module defines operations for the following /api/v1/base endpoint
"""
import logging

from fastapi import APIRouter, status

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/", status_code=status.HTTP_200_OK)
async def hello():
    """
    This endpoint returns Hello World
    """
    return {"message": "Hello World"}

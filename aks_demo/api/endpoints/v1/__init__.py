"""This module defines the main router among all api/v1 endpoints"""

from fastapi import APIRouter, Depends

from aks_demo.api.endpoints.v1.prediction import router as prediction_router
from aks_demo.api.endpoints.v1.hello import router as hello_router
from aks_demo.api.dependencies.common import api_key_header

router = APIRouter()

router.include_router(
    hello_router, prefix="/hello", tags=["Hello"], dependencies=[],
)

router.include_router(
    prediction_router,
    prefix="/prediction",
    tags=["Prediction"],
    dependencies=[Depends(api_key_header)],
)

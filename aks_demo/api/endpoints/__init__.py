"""This module defines the main router among all endpoints"""

from fastapi import APIRouter

from aks_demo.api.endpoints.v1 import router as api_v1_router
from aks_demo.settings import FastApiConfig

router = APIRouter()

router.include_router(api_v1_router, prefix=f"{FastApiConfig.API_PREFIX}")

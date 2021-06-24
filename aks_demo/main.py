"""This modules configures the FastAPI application"""

import logging
import sys

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, RedirectResponse

from aks_demo.api.endpoints import router as main_router
from aks_demo.api.exceptions import InvalidSecretKeyError
from aks_demo.settings import FastApiConfig

# Setup loggers
logging.basicConfig(
    stream=sys.stdout,
    format="%(asctime)s.%(msecs)03d %(levelname)s %(module)s - %(funcName)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    level=logging.INFO,
)

# Initialise FastAPI app
app = FastAPI(
    title=FastApiConfig.PROJECT_NAME,
    description=FastApiConfig.PROJECT_DESCRIPTION,
    version=FastApiConfig.VERSION,
    openapi_url=f"{FastApiConfig.API_PREFIX}/openapi.json",
    docs_url=f"{FastApiConfig.API_PREFIX}/docs",
    redoc_url=None,
)


@app.exception_handler(InvalidSecretKeyError)
# pylint: disable=unused-argument
async def invalid_secret_key_handler(request: Request, exc: InvalidSecretKeyError):
    """Register the InvalidSecretKeyError exception to the FastAPI app"""
    return JSONResponse(
        status_code=418, content={"message": f"InvalidSecretKeyError: {exc.name}"},
    )


# Register routes
@app.get("/", include_in_schema=False)
async def redirect_to_api_docs():
    """Redirect GET requests: "/" -> "/api/v1/docs"""
    return RedirectResponse(f"{FastApiConfig.API_PREFIX}/docs")


app.include_router(main_router, prefix="")  # Load all routes

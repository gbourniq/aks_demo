"""
This module defines common dependencies such as common query parameters
"""

from typing import NoReturn

from fastapi import Header

from aks_demo.api.exceptions import InvalidSecretKeyError
from aks_demo.settings import SECRET_KEY_HEADER


async def api_key_header(api_key: str = Header(...),) -> NoReturn:
    """Depency to retrieve / validate the X-Api-Key header."""
    if api_key != str(SECRET_KEY_HEADER):
        raise InvalidSecretKeyError(name="X-Api-Key invalid")  # returns a 400
    return api_key

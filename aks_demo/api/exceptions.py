"""This module defines custom exceptions"""


class InvalidSecretKeyError(Exception):
    """
    InvalidSecretKeyError to be raised when the given
    secret key head is invalid
    """

    # pylint: disable=super-init-not-called
    def __init__(self, name: str):
        self.name = name

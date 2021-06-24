"""
This module is to run the fastapi webserver and is used
as a container entrypoint script
"""

import uvicorn

from aks_demo.settings import UvicornConfig

if __name__ == "__main__":

    uvicorn.run(
        UvicornConfig.FASTAPI_APP,
        host=UvicornConfig.WEBSERVER_HOST,
        port=UvicornConfig.WEBSERVER_PORT,
        reload=UvicornConfig.RELOAD,
        debug=UvicornConfig.DEBUG,
        workers=UvicornConfig.WORKERS_COUNT,
    )

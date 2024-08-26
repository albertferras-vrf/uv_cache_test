# /// script
# dependencies = [
#   "fastapi",
#   "uvicorn",
#   "requests"
# ]
# ///
import json
import time

import uvicorn
from fastapi import FastAPI
import requests
import os

from starlette.responses import HTMLResponse

app = FastAPI()
CACHE_DIR = os.path.join(os.path.dirname(__file__), "cache")
PYPI_INDEX_URL = "https://pypi.org/simple/"
DELAY_GET_PACKAGE_PAGE = 0.15


def _resolve(package_name: str, html_response_no_cache: bool = False):
    cache_path = os.path.join(CACHE_DIR, f"index_{package_name}.json")
    if not os.path.exists(cache_path):
        pypi_response = requests.get(PYPI_INDEX_URL + package_name + "/")
        content = pypi_response.text
        headers = pypi_response.headers
        with open(cache_path, "wt") as f:
            json.dump({"content": content, "headers": dict(headers)}, f)
    else:
        with open(cache_path, "rt") as f:
            cached = json.load(f)
            content = cached['content']
            headers = cached['headers']

    if html_response_no_cache:
        # Tell client to not cache this response
        headers2 = {
            "Cache-Control": "no-store, no-cache, must-revalidate, proxy-revalidate"
        }
    else:
        # Copy Cache-Control header from PYPI
        headers2 = {
            "Cache-Control": headers.get("Cache-Control", "")
        }
    return HTMLResponse(content=content.encode("utf-8"), headers=headers2)


@app.get("/cached/{package_name}/")
async def package_get_cached(package_name: str):
    time.sleep(DELAY_GET_PACKAGE_PAGE)
    return _resolve(package_name, html_response_no_cache=False)


@app.get("/no_cache/{package_name}/")
async def package_get_not_cached(package_name: str):
    time.sleep(DELAY_GET_PACKAGE_PAGE)
    return _resolve(package_name, html_response_no_cache=True)


if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)

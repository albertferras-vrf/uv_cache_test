#!/bin/sh

uninstall_packages() {
  uv pip freeze | grep -v "^uv==" | grep -v '\-e' | xargs uv pip uninstall
}

# prepare virtualenv to run our tests
uv sync
uv venv activate
uv cache clean

echo "--------------------------------------------"
echo "Public PYPI PROXY"
uv pip install --index-url https://pypi.org/simple/ -r requirements.txt
uninstall_packages
echo "Reinstall"
uv pip install --index-url http://pypi.org/simple/ -r requirements.txt
uninstall_packages

echo "--------------------------------------------"
echo "LOCAL PYPI PROXY (keep cache-control header)"
uv pip install --index-url http://localhost:8000/cached/ -r requirements.txt
uninstall_packages
echo "Reinstall"
uv pip install --index-url http://localhost:8000/cached/ -r requirements.txt
uninstall_packages

echo "--------------------------------------------"
echo "LOCAL PYPI PROXY (cache-control: no-cache)"
uv pip install --index-url http://localhost:8000/no_cache/ -r requirements.txt
uninstall_packages
echo "Reinstall"
# This is the command which has slow Resolve
uv pip install --index-url http://localhost:8000/no_cache/ -r requirements.txt
uninstall_packages

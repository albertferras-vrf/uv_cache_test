#!/bin/sh

uninstall_packages() {
  pip freeze | grep -v "^uv==" | grep -v '\-e' | xargs pip uninstall -y -q
}

pip cache purge

echo "--------------------------------------------"
echo "Public PYPI PROXY"
time pip install -q --index-url https://pypi.org/simple/ -r requirements.txt
uninstall_packages
echo "Reinstall"
time pip install -q --index-url https://pypi.org/simple/ -r requirements.txt
uninstall_packages

echo "--------------------------------------------"
echo "LOCAL PYPI PROXY (keep cache-control header)"
time pip install -q --index-url http://localhost:8000/cached/ -r requirements.txt
uninstall_packages
echo "Reinstall"
time pip install --index-url http://localhost:8000/cached/ -r requirements.txt
uninstall_packages

echo "--------------------------------------------"
echo "LOCAL PYPI PROXY (cache-control: no-cache)"
time pip install -q --index-url http://localhost:8000/no_cache/ -r requirements.txt
uninstall_packages
echo "Reinstall"
# This is the command which has slow Resolve
time pip install --index-url http://localhost:8000/no_cache/ -r requirements.txt
uninstall_packages

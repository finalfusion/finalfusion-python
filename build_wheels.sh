#!/bin/bash
set -ex

cd io

for PYBIN in /opt/python/cp{36,37,38}*/bin; do
    export PYTHON_SYS_EXECUTABLE="$PYBIN/python"
    "${PYBIN}/pip" install cython setuptools wheel
    "${PYBIN}/python" setup.py bdist_wheel
    if [[ $PYBIN == "/opt/python/cp36-cp36m/bin" ]]
      then
        "${PYBIN}/python" setup.py sdist
    fi
done

for whl in dist/*.whl; do
    auditwheel repair "$whl"
done

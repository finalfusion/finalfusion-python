#!/bin/bash
set -ex

cd io
export MANYLINUX=1
for PYBIN in /opt/python/cp{36,37,38}*/bin; do
    "${PYBIN}/pip" install cython setuptools wheel
    "${PYBIN}/python" setup.py bdist_wheel
    rm -f src/finalfusion/subword/*.c
    if [[ $PYBIN == "/opt/python/cp36-cp36m/bin" ]]
      then
        "${PYBIN}/python" setup.py sdist
        rm -f src/finalfusion/subword/*.c
    fi
done

for whl in dist/*.whl; do
    auditwheel repair "$whl"
done

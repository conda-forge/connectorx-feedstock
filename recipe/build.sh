#!/bin/bash

set -ex

export PYO3_PYTHON_VERSION=${PY_VER}

maturin build --no-sdist --release --strip --manylinux off --interpreter="${PYTHON}" -m connectorx-python/Cargo.toml

"${PYTHON}" -m pip install $SRC_DIR/connectorx-python/target/wheels/*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml 

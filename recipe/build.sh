#!/bin/bash

set -ex

export PYO3_PYTHON_VERSION=${PY_VER}
export BINDGEN_EXTRA_CLANG_ARGS="$CFLAGS"
export LIBCLANG_PATH=$BUILD_PREFIX/lib/libclang${SHLIB_EXT}

maturin build --release --strip --manylinux off --interpreter="${PYTHON}" -m connectorx-python/Cargo.toml

"${PYTHON}" -m pip install $SRC_DIR/connectorx-python/target/wheels/*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml 

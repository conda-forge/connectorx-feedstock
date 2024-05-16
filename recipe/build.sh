#!/bin/bash

set -ex

export BINDGEN_EXTRA_CLANG_ARGS="$CFLAGS"
export LIBCLANG_PATH=$BUILD_PREFIX/lib/libclang${SHLIB_EXT}

cargo feature pyo3 +abi3-py38 --manifest-path connectorx-python/Cargo.toml
maturin build --release --strip --manylinux off --interpreter="${PYTHON}" --manifest-path connectorx-python/Cargo.toml

"${PYTHON}" -m pip install $SRC_DIR/connectorx-python/target/wheels/*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml 

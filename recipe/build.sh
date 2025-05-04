#!/bin/bash

set -ex

export BINDGEN_EXTRA_CLANG_ARGS="$CFLAGS"
export LIBCLANG_PATH=$BUILD_PREFIX/lib/libclang${SHLIB_EXT}

if [[ "${target_platform}" == linux-* ]]; then
  export RUSTFLAGS="-C link-arg=-Wl,-rpath-link,${PREFIX}/lib -C link-arg=-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"
fi

if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  export CFLAGS=${CFLAGS//-fno-plt/}
  export CXXFLAGS=${CXXFLAGS//-fno-plt/}
fi

maturin build --release --strip --manylinux off --interpreter="${PYTHON}" -m connectorx-python/Cargo.toml

"${PYTHON}" -m pip install $SRC_DIR/connectorx-python/target/wheels/*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml 

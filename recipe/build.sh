#!/bin/bash

set -ex

if [[ "${target_platform}" == osx-* ]]; then
  export SDKROOT="${CONDA_BUILD_SYSROOT}"
  export BINDGEN_EXTRA_CLANG_ARGS="$CFLAGS -isysroot ${CONDA_BUILD_SYSROOT}"

  # The libgssapi-sys crate hardcodes the system SDK framework path in its
  # build.rs, causing bindgen to pick up system framework headers that the
  # bundled libclang cannot parse. Patch it to use the conda SDK instead.
  cargo fetch --manifest-path connectorx-python/Cargo.toml
  _CARGO_REGISTRY="${CARGO_HOME:-${BUILD_PREFIX}/.cargo}/registry/src"
  find "${_CARGO_REGISTRY}" -path "*/libgssapi-sys-*/build.rs" \
    -exec sed -i.bak "s|-F/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks|-F${CONDA_BUILD_SYSROOT}/System/Library/Frameworks|g" {} +
else
  export BINDGEN_EXTRA_CLANG_ARGS="$CFLAGS"
fi
export LIBCLANG_PATH=$BUILD_PREFIX/lib/libclang${SHLIB_EXT}

if [[ "${target_platform}" == linux-* ]]; then
  export RUSTFLAGS="-C link-arg=-Wl,-rpath-link,${PREFIX}/lib -C link-arg=-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"
fi

if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  export CFLAGS=${CFLAGS//-fno-plt/}
  export CXXFLAGS=${CXXFLAGS//-fno-plt/}
fi

maturin build --release --strip --manylinux off --interpreter="${PYTHON}" -m connectorx-python/Cargo.toml

_WHEEL_FILE=("${SRC_DIR}"/connectorx-python/target/wheels/*.whl)
"${PYTHON}" -m installer --prefix "${PREFIX}" "${_WHEEL_FILE[0]}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml 

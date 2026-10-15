#!/bin/bash

set -ex

if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  export CFLAGS=${CFLAGS//-fno-plt/}
  export CXXFLAGS=${CXXFLAGS//-fno-plt/}
  export CFLAGS_powerpc64le_unknown_linux_gnu="${CFLAGS}"
  export CXXFLAGS_powerpc64le_unknown_linux_gnu="${CXXFLAGS}"
  export CC_powerpc64le_unknown_linux_gnu="${CC}"
fi

export BINDGEN_EXTRA_CLANG_ARGS="$CFLAGS"
export LIBCLANG_PATH=$BUILD_PREFIX/lib/libclang${SHLIB_EXT}

if [[ "${target_platform}" == osx-* ]]; then
  sed -i.bak '/"integrated-auth-gssapi",/d' connectorx/Cargo.toml
  rm connectorx/Cargo.toml.bak
  export SDKROOT="${CONDA_BUILD_SYSROOT}"
  export BINDGEN_EXTRA_CLANG_ARGS="${BINDGEN_EXTRA_CLANG_ARGS} -isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} -F${CONDA_BUILD_SYSROOT}/System/Library/Frameworks"
fi

if [[ "${target_platform}" == linux-* ]]; then
  export RUSTFLAGS="-C link-arg=-Wl,-rpath-link,${PREFIX}/lib -C link-arg=-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"
fi

if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  export RUSTFLAGS="${RUSTFLAGS} -C link-self-contained=no -C link-arg=-fuse-ld=bfd"
  export CFLAGS=
  export CXXFLAGS=
fi

maturin build --release --strip --manylinux off --interpreter="${PYTHON}" -m connectorx-python/Cargo.toml

"${PYTHON}" -m pip install $SRC_DIR/connectorx-python/target/wheels/*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml 

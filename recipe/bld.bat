@echo on

set "PYO3_PYTHON=%PYTHON%"
set OPENSSL_NO_VENDOR=1
set "OPENSSL_DIR=%LIBRARY_PREFIX%"

cp %SRC_DIR%\README.md %SRC_DIR%\connectorx-python\README.md
cp %SRC_DIR%\LICENSE %SRC_DIR%\connectorx-python\LICENSE

set "CMAKE_GENERATOR=NMake Makefiles"
cd connectorx-python
%PYTHON% -m pip install --ignore-installed --no-deps -vv .
@rem maturin build --no-sdist --release --strip --manylinux off --interpreter=%PYTHON% -m connectorx-python/Cargo.toml
if errorlevel 1 exit 1

@rem FOR /F "delims=" %%i IN ('dir /s /b target\wheels\*.whl') DO set connectorx_wheel=%%i
@rem %PYTHON% -m pip install --ignore-installed --no-deps %connectorx_wheel% -vv
@rem if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

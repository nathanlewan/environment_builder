@echo off
for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

cd %api_SCRIPTROOTDIR%
cd ..
cd ..
cd ..

set "api_ENVROOTDIR=%CD%"


echo "[environment_variables]:                        setting root directory to [%api_ENVROOTDIR%]"







set "api_NODEVERSION=node-v16.13.2-windows-x64"
set "api_NODEPATH=%api_ENVROOTDIR%\lib\bin\windows\node\%api_NODEVERSION%"
set "api_PYTHONVERSION=cpython-3.10.0-aarch64-unknown-linux-gnu-noopt-20211017T1616"
set "api_PYTHONPATH=%api_ENVROOTDIR%\lib\bin\windows\python\%api_PYTHONVERSION%"
set "api_PATH=%api_ENVROOTDIR%\lib\setup\windows;%api_NODEPATH%\bin;%api_PYTHONPATH%\install\bin"
set "PATH=%api_PATH%:%PATH%"

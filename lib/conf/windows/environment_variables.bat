@echo off
for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

cd %api_SCRIPTROOTDIR%
cd ..
cd ..
cd ..

set "api_ENVROOTDIR=%CD%"


echo "[environment_variables]:                        setting root directory to [%api_ENVROOTDIR%]"







set "api_ENVROOTDIR=%api_ENVROOTDIR%"
set "api_NODEVERSION=node-v16.13.2-windows-x64"
set "api_NODEPATH=%api_ENVROOTDIR%\lib\bin\windows\node\%api_NODEVERSION%"
set "api_PATH=%api_ENVROOTDIR%\lib\setup\windows;%api_NODEPATH%"
set "PATH=%api_PATH%;%PATH%"

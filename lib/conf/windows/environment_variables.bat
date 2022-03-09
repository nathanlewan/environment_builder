@echo off
for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

cd %api_SCRIPTROOTDIR%
cd ..
cd ..
cd ..

set "api_0ENVROOTDIR=%CD%"


echo "[environment_variables]:                        setting root directory to [%api_0ENVROOTDIR%]"







set "api_0ENVROOTDIR=%api_0ENVROOTDIR%"
set "api_1NODEVERSION=node-v16.13.2-windows-x64"
set "api_2NODEPATH=%api_0ENVROOTDIR%\lib\bin\windows\node\%api_1NODEVERSION%"
set "api_3PATH=%api_0ENVROOTDIR%\lib\setup\windows;%api_2NODEPATH%"
set "PATH=%api_3PATH%;%PATH%"

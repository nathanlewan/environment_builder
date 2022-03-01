@echo off
setlocal EnableExtensions

for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

echo "[install_node]:                                 script location: [%api_SCRIPTROOTDIR%]"

cd %api_SCRIPTROOTDIR%
cd ..
cd ..
cd ..

set "api_ENVROOTDIR=%CD%"


echo "[install_node]:                                 setting root directory to [%api_ENVROOTDIR%]"


rem check if environment is set up
set "initRunFromNode=no"

if "%API_NODEPATH%"=="" (
    echo "[install_node]:                                 nodejs env variables not set, running init_environment"
    set "initRunFromNode=yes"
    call %api_ENVROOTDIR%\lib\setup\windows\init_environment.bat
)

echo "[install_node]:                                 setting up %api_NODEVERSION%"
if not exist "%api_ENVROOTDIR%\lib\bin\" mkdir "%api_ENVROOTDIR%\lib\bin"
if not exist "%api_ENVROOTDIR%\lib\bin\windows\" mkdir "%api_ENVROOTDIR%\lib\bin\windows"
if not exist "%api_ENVROOTDIR%\lib\bin\windows\node\" mkdir "%api_ENVROOTDIR%\lib\bin\windows\node"
if not exist "%api_ENVROOTDIR%\lib\bin\windows\node\%api_NODEVERSION%\" mkdir "%api_ENVROOTDIR%\lib\bin\windows\node\%api_NODEVERSION%"


IF NOT EXIST "%api_ENVROOTDIR%\lib\bin\windows\node\%api_NODEVERSION%\node.exe" (
    call %api_ENVROOTDIR%\lib\setup\windows\src\environmentVar.exe -extractZip "%api_ENVROOTDIR%\lib\installers\windows\%api_NODEVERSION%.zip" "%api_ENVROOTDIR%\lib\bin\windows\node\%api_NODEVERSION%"   
)


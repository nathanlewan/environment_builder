@echo off
setlocal EnableExtensions

for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

echo "[install_node]:                                 script location: [%api_SCRIPTROOTDIR%]"

cd %api_SCRIPTROOTDIR%
cd ..
cd ..
cd ..

set "api_0ENVROOTDIR=%CD%"


echo "[install_node]:                                 setting root directory to [%api_0ENVROOTDIR%]"


rem check if environment is set up
set "initRunFromNode=no"

if "%API_2NODEPATH%"=="" (
    echo "[install_node]:                                 nodejs env variables not set, running init_environment"
    set "initRunFromNode=yes"
    call %api_0ENVROOTDIR%\lib\setup\windows\init_environment.bat
)

echo "[install_node]:                                 setting up %api_1NODEVERSION%"
if not exist "%api_0ENVROOTDIR%\lib\bin\" mkdir "%api_0ENVROOTDIR%\lib\bin"
if not exist "%api_0ENVROOTDIR%\lib\bin\windows\" mkdir "%api_0ENVROOTDIR%\lib\bin\windows"
if not exist "%api_0ENVROOTDIR%\lib\bin\windows\node\" mkdir "%api_0ENVROOTDIR%\lib\bin\windows\node"
if not exist "%api_0ENVROOTDIR%\lib\bin\windows\node\%api_1NODEVERSION%\" mkdir "%api_0ENVROOTDIR%\lib\bin\windows\node\%api_1NODEVERSION%"


IF NOT EXIST "%api_0ENVROOTDIR%\lib\bin\windows\node\%api_1NODEVERSION%\node.exe" (
    call %api_ENVROOTDIR%\lib\setup\windows\src\environmentVar.exe -extractZip "%api_ENVROOTDIR%\lib\installers\windows\%api_1NODEVERSION%.zip" "%api_ENVROOTDIR%\lib\bin\windows\node\%api_1NODEVERSION%"   
)


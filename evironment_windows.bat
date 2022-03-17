@echo off
setlocal EnableExtensions

for %%i in ("%~dp0.") do SET "SCRIPT_ROOT_DIR=%%~fi"

echo "[init_environment]:                             setting root directory to [%SCRIPT_ROOT_DIR%]"

call %SCRIPT_ROOT_DIR%\lib\setup\windows\init_environment.bat
call %SCRIPT_ROOT_DIR%\lib\setup\windows\environmentVar.exe -launchConsoleEnvironment
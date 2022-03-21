@echo off
setlocal EnableExtensions

for %%i in ("%~dp0.") do SET "SCRIPT_ROOT_DIR=%%~fi"

echo "[init_environment]:                             setting root directory to [%SCRIPT_ROOT_DIR%]"

call Powershell.exe -ExecutionPolicy Bypass -File %SCRIPT_ROOT_DIR%\lib\functions\windows\environment_windows.ps1

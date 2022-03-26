@echo off
setlocal EnableExtensions

for %%i in ("%~dp0.") do SET "SCRIPT_ROOT_DIR=%%~fi"


call Powershell.exe -NoExit -ExecutionPolicy Bypass -File %SCRIPT_ROOT_DIR%\lib\functions\windows\environment_windows.ps1

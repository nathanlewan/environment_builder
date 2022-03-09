@echo off
setlocal EnableExtensions

for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

echo "[init_environment]:                             setting root directory to [%api_SCRIPTROOTDIR%]"

call %api_SCRIPTROOTDIR%\lib\setup\windows\init_environment.bat
call %api_SCRIPTROOTDIR%\lib\setup\windows\environmentVar.exe -launchConsoleEnvironment
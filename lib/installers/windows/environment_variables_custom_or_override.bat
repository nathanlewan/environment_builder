@echo off
for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

cd %api_SCRIPTROOTDIR%
cd ..
cd ..
cd ..

set "api_0ENVROOTDIR=%CD%"


echo "[environment_variables_custom_or_override]:     setting root directory to [%api_0ENVROOTDIR%]"








rem
rem DON'T MODIFY ABOVE THIS PART
rem

rem list environment variables below here
rem if the variable already exists, it will be overwritten by what's here
rem example
rem set "MYVARIABLE=example"
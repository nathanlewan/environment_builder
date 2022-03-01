@echo off
setlocal EnableExtensions

for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

cd %api_SCRIPTROOTDIR%
cd ..
cd ..
cd ..

set "api_ENVROOTDIR=%CD%"

echo "[init_environment]:                             setting root directory to [%api_ENVROOTDIR%]"








if not exist "%api_ENVROOTDIR%/lib/conf/windows/environment_variables_custom_or_override.bat" (
    echo "[init_environment]:                             copying over environment variable override script"
    echo "[init_environment]:                             location: [%api_ENVROOTDIR%\lib\conf\windows\environment_variables_custom_or_override]"
    C:\Windows\System32\ROBOCOPY %api_ENVROOTDIR%\lib\installers\windows\ %api_ENVROOTDIR%\lib\conf\windows\ environment_variables_custom_or_override.bat /copy:dat /e /NFL /NDL /NJH /NJS /nc /ns /np

)

call %api_ENVROOTDIR%\lib\conf\windows\environment_variables.bat
call %api_ENVROOTDIR%\lib\conf\windows\environment_variables_custom_or_override.bat
call %api_ENVROOTDIR%\lib\setup\windows\create_envrc.bat
call %api_ENVROOTDIR%\lib\setup\windows\hide_files.bat
call %api_ENVROOTDIR%\lib\setup\windows\install_node.bat
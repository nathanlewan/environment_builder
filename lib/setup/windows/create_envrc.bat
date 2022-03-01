@echo off
setlocal EnableExtensions

for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

echo "[create_envrc]:                                 script location: [%api_SCRIPTROOTDIR%]"

cd %api_SCRIPTROOTDIR%
cd ..
cd ..
cd ..

set "api_ENVROOTDIR=%CD%"


echo "[create_envrc]:                                 setting root directory to [%api_ENVROOTDIR%]"







if exist "%api_ENVROOTDIR%\.envrc.bat" (
    echo "[create_envrc]:                                 removing [%api_ENVROOTDIR%\.envrc.bat] so we can regenerate it"
    del /F /Q /AH "%api_ENVROOTDIR%\.envrc.bat"

)


if exist "%api_ENVROOTDIR%\.tmp_envrc.bat" (
    echo "[create_envrc]:                                 removing [%api_ENVROOTDIR%\.tmp_envrc.bat] so we can regenerate it"
    del /F /Q /AH "%api_ENVROOTDIR%\.tmp_envrc.bat"
)

if exist "%api_ENVROOTDIR%\.tmp_ovr_envrc.bat" (
    echo "[create_envrc]:                                 removing [%api_ENVROOTDIR%\.tmp_ovr_envrc.bat] so we can regenerate it"
    del /F /Q /AH "%api_ENVROOTDIR%\.tmp_ovr_envrc.bat"
)


findstr /R /C:"^set .*" %api_ENVROOTDIR%\lib\setup\windows\init_environment.bat >> %api_ENVROOTDIR%\.tmp_envrc.bat
findstr /R /C:"^set .*" %api_ENVROOTDIR%\lib\conf\windows\environment_variables.bat >> %api_ENVROOTDIR%\.tmp_envrc.bat
findstr /R /C:"^set .*" %api_ENVROOTDIR%\lib\conf\windows\environment_variables_custom_or_override.bat >> %api_ENVROOTDIR%\.tmp_ovr_envrc.bat

call %api_ENVROOTDIR%\lib\setup\windows\environmentVar.exe -compileEnvRc %api_ENVROOTDIR%\.tmp_envrc.bat %api_ENVROOTDIR%\.tmp_ovr_envrc.bat
call %api_ENVROOTDIR%\lib\setup\windows\environmentVar.exe -importEnvironmentVars
@echo off
setlocal EnableExtensions

for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

echo "[hide_files]:                                   script location: [%api_SCRIPTROOTDIR%]"

cd %api_SCRIPTROOTDIR%
cd ..
cd ..
cd ..

set "api_0ENVROOTDIR=%CD%"


echo "[hide_files]:                                   setting root directory to [%api_0ENVROOTDIR%]"

if exist "%api_0ENVROOTDIR%\.gitignore" (
    echo "[hide_files]:                                   hiding [.gitignore]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\.gitignore
)

if exist "%api_0ENVROOTDIR%\.npmrc" (
    echo "[hide_files]:                                   hiding [.npmrc]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\.npmrc
)

if exist "%api_0ENVROOTDIR%\LICENSE" (
    echo "[hide_files]:                                   hiding [LICENSE]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\LICENSE
)

if exist "%api_0ENVROOTDIR%\package.json" (
    echo "[hide_files]:                                   hiding [package.json]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\package.json
)

if exist "%api_0ENVROOTDIR%\package-lock.json" (
    echo "[hide_files]:                                   hiding [package-lock.json]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\package-lock.json
)

if exist "%api_0ENVROOTDIR%\lib\conf\linux" (
    echo "[hide_files]:                                   hiding [%api_0ENVROOTDIR%\lib\conf\linux]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\lib\conf\linux
)

if exist "%api_0ENVROOTDIR%\lib\installers\linux" (
    echo "[hide_files]:                                   hiding [%api_0ENVROOTDIR%\lib\installers\linux]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\lib\installers\linux
)

if exist "%api_0ENVROOTDIR%\lib\setup\linux" (
    echo "[hide_files]:                                   hiding [%api_0ENVROOTDIR%\lib\setup\linux]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\lib\setup\linux
)

if exist "%api_0ENVROOTDIR%\.tmp_envrc.bat" (
    echo "[hide_files]:                                   hiding [%api_0ENVROOTDIR%\.tmp_envrc.bat]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\.tmp_envrc.bat
)

if exist "%api_0ENVROOTDIR%\.tmp_ovr_envrc.bat" (
    echo "[hide_files]:                                   hiding [%api_0ENVROOTDIR%\.tmp_ovr_envrc.bat]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\.tmp_ovr_envrc.bat
)

if exist "%api_0ENVROOTDIR%\.envrc.bat" (
    echo "[hide_files]:                                   hiding [%api_0ENVROOTDIR%\.envrc.bat]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\.envrc.bat
)

if exist "%api_0ENVROOTDIR%\lib\setup\windows\src" (
    echo "[hide_files]:                                   hiding [%api_0ENVROOTDIR%\lib\setup\windows\src]"
    C:\Windows\System32\attrib +h %api_0ENVROOTDIR%\lib\setup\windows\src
)
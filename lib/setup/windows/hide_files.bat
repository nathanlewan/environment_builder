@echo off
for %%i in ("%~dp0.") do SET "api_SCRIPTROOTDIR=%%~fi"

echo "[hide_files]:                                   script location: [%api_SCRIPTROOTDIR%]"

cd %api_SCRIPTROOTDIR%
cd ..
cd ..
cd ..

set "api_ENVROOTDIR=%CD%"


echo "[hide_files]:                                   setting root directory to [%api_ENVROOTDIR%]"

if exist "%api_ENVROOTDIR%\.gitignore" (
    echo "[hide_files]:                                   hiding [.gitignore]"
    C:\Windows\System32\attrib +h %api_ENVROOTDIR%\.gitignore
)

if exist "%api_ENVROOTDIR%\.npmrc" (
    echo "[hide_files]:                                   hiding [.npmrc]"
    C:\Windows\System32\attrib +h %api_ENVROOTDIR%\.npmrc
)

if exist "%api_ENVROOTDIR%\LICENSE" (
    echo "[hide_files]:                                   hiding [LICENSE]"
    C:\Windows\System32\attrib +h %api_ENVROOTDIR%\LICENSE
)

if exist "%api_ENVROOTDIR%\package.json" (
    echo "[hide_files]:                                   hiding [package.json]"
    C:\Windows\System32\attrib +h %api_ENVROOTDIR%\package.json
)

if exist "%api_ENVROOTDIR%\package-lock.json" (
    echo "[hide_files]:                                   hiding [package-lock.json]"
    C:\Windows\System32\attrib +h %api_ENVROOTDIR%\package-lock.json
)

if exist "%api_ENVROOTDIR%\lib\conf\linux" (
    echo "[hide_files]:                                   hiding [%api_ENVROOTDIR%\lib\conf\linux]"
    C:\Windows\System32\attrib +h %api_ENVROOTDIR%\lib\conf\linux
)

if exist "%api_ENVROOTDIR%\lib\installers\linux" (
    echo "[hide_files]:                                   hiding [%api_ENVROOTDIR%\lib\installers\linux]"
    C:\Windows\System32\attrib +h %api_ENVROOTDIR%\lib\installers\linux
)

if exist "%api_ENVROOTDIR%\lib\setup\linux" (
    echo "[hide_files]:                                   hiding [%api_ENVROOTDIR%\lib\setup\linux]"
    C:\Windows\System32\attrib +h %api_ENVROOTDIR%\lib\setup\linux
)




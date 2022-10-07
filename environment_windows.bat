@echo off
setlocal EnableExtensions

SET "PSHELLVERS=PowerShell-7.2.4-win-x64"
SET "PSHELLVERSONLY=v7.2.4"

for %%i in ("%~dp0.") do SET "SCRIPT_ROOT_DIR=%%~fi"

rem move 7zip into position
if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.7zip\7zip\App\7-Zip64\7z.exe" (

    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows"
    )
    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.7zip" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows\.7zip"
    )
    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.7zip\7zip" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows\.7zip\7zip"
    )

    C:\Windows\System32\ROBOCOPY.exe %SCRIPT_ROOT_DIR%\lib\binary_installers\windows\7zip\7zip %SCRIPT_ROOT_DIR%\bin\.windows\.7zip\7zip /copy:dat /e /np /njh /njh /LOG:%temp%\temp.txt

)
if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\7z.LNK" (
    cscript.exe %SCRIPT_ROOT_DIR%\lib\functions\windows\Create_Shortcut.vbs "%SCRIPT_ROOT_DIR%\bin\7z.LNK" "%SCRIPT_ROOT_DIR%\bin\.windows\.7zip\7zip\App\7-Zip64\7z.exe" "%SCRIPT_ROOT_DIR%\bin\.windows\.7zip\7zip\App\7-Zip64\"
)


rem move curl into position
if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.curl\curl\curl-7.83.1-win64-mingw\bin\curl.exe" (

    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows"
    )
    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.curl" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows\.curl"
    )
    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.curl\curl" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows\.curl\curl"
    )

    %SCRIPT_ROOT_DIR%\bin\7z.lnk x "%SCRIPT_ROOT_DIR%\lib\binary_installers\windows\curl\curl.zip" -o"%SCRIPT_ROOT_DIR%\bin\.windows\.curl\curl"
)
if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\curl.LNK" (
    cscript.exe %SCRIPT_ROOT_DIR%\lib\functions\windows\Create_Shortcut.vbs "%SCRIPT_ROOT_DIR%\bin\curl.LNK" "%SCRIPT_ROOT_DIR%\bin\.windows\.curl\curl\curl-7.83.1-win64-mingw\bin\curl.exe" "%SCRIPT_ROOT_DIR%\bin\.windows\.curl\curl\curl-7.83.1-win64-mingw\bin\"
)


rem get powershell and move into position
if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%.zip" (

    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows"
    )
    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell"
    )

    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%"
    )

    %SCRIPT_ROOT_DIR%\bin\curl.lnk -L https://github.com/PowerShell/PowerShell/releases/download/%PSHELLVERSONLY%/%PSHELLVERS%.zip --output %SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%.zip 
)
if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%\pwsh.exe" (
    %SCRIPT_ROOT_DIR%\bin\7z.lnk x "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%.zip" -o"%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%"
)
if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\pwsh.LNK" (
    cscript.exe %SCRIPT_ROOT_DIR%\lib\functions\windows\Create_Shortcut.vbs "%SCRIPT_ROOT_DIR%\bin\pwsh.LNK" "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%\pwsh.exe" "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%\"
) else (
    del "%SCRIPT_ROOT_DIR%\bin\pwsh.LNK"
    cscript.exe %SCRIPT_ROOT_DIR%\lib\functions\windows\Create_Shortcut.vbs "%SCRIPT_ROOT_DIR%\bin\pwsh.LNK" "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%\pwsh.exe" "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\%PSHELLVERS%\"
)



call "%SCRIPT_ROOT_DIR%\bin\pwsh.LNK" -NoExit -ExecutionPolicy Bypass -File "%SCRIPT_ROOT_DIR%\lib\functions\windows\environment_windows.ps1"

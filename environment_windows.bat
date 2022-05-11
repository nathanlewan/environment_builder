@echo off
setlocal EnableExtensions

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
if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\PowerShell-7.2.3-win-x64.zip" (

    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows"
    )
    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell"
    )

    if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\powershell" (
        mkdir "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\powershell"
    )

    %SCRIPT_ROOT_DIR%\bin\curl.lnk -L https://github.com/PowerShell/PowerShell/releases/download/v7.2.3/PowerShell-7.2.3-win-x64.zip --output %SCRIPT_ROOT_DIR%\bin\.windows\.powershell\PowerShell-7.2.3-win-x64.zip 
)
if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\powershell\pwsh.exe" (
    %SCRIPT_ROOT_DIR%\bin\7z.lnk x "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\PowerShell-7.2.3-win-x64.zip" -o"%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\powershell"
)
if NOT EXIST "%SCRIPT_ROOT_DIR%\bin\pwsh.LNK" (
    cscript.exe %SCRIPT_ROOT_DIR%\lib\functions\windows\Create_Shortcut.vbs "%SCRIPT_ROOT_DIR%\bin\pwsh.LNK" "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\powershell\pwsh.exe" "%SCRIPT_ROOT_DIR%\bin\.windows\.powershell\powershell\"
)



call "%SCRIPT_ROOT_DIR%\bin\pwsh.LNK" -NoExit -ExecutionPolicy Bypass -File "%SCRIPT_ROOT_DIR%\lib\functions\windows\environment_windows.ps1"

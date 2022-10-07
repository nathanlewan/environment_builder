param (
    $resetEnvironment = $false
)

$ENVIRONMENT_ROOT_DIR = $MyInvocation.MyCommand.Path
$ENVIRONMENT_ROOT_DIR = $ENVIRONMENT_ROOT_DIR.replace("\environment_windows.ps1","")

Set-Location $ENVIRONMENT_ROOT_DIR
set-location ..
set-location ..
set-location ..
$ENVIRONMENT_ROOT_DIR = get-location
. $ENVIRONMENT_ROOT_DIR\lib\functions\windows\environment_functions.ps1



generateDefaultConfFolderStructure
generateDefaultEnvCustomFile
generateDefaultEnvAppFile
generateDefaultEnvFile -deleteFlag "reset"
generateDefaultEnvFile

generateDefaultBinFolderStructure


$packageModules = get-childitem "$($ENVIRONMENT_ROOT_DIR)\lib\package_modules\windows\"

foreach ($script in $packageModules) {
    . "$($ENVIRONMENT_ROOT_DIR)\lib\package_modules\windows\$($script.name)"
}

setupDefaultEnvironmentVariables
applyDefaultEnvironmentVariables

if ($resetEnvironment) {
    resetEnvSetup
    exit
}

Clear-Host
write-host " "
write-host "**************************************************"
write-host "** New terminal session with environment set up **"
write-host "** When done be sure to 'exit' this terminal    **"
write-host "**************************************************"
write-host " "


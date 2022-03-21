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
. $ENVIRONMENT_ROOT_DIR/lib/functions/windows/environment_functions.ps1

if ($resetEnvironment) {
    resetEnvSetup
} else {
    echo "hello"
}
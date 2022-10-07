$ENVIRONMENT_ROOT_DIR = $MyInvocation.MyCommand.Path
$ENVIRONMENT_ROOT_DIR = $ENVIRONMENT_ROOT_DIR.replace("\environment_functions.ps1","")

Set-Location $ENVIRONMENT_ROOT_DIR
set-location ..
set-location ..
set-location ..
$ENVIRONMENT_ROOT_DIR = get-location



Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function generateDefaultEnvCustomFile {

    param (
        $deleteFlag
    )

    # if argument '-reset' is passed, delete env_custom file
    if ( $deleteFlag -eq "reset" ) {

        if ( $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\conf\env_custom") ) {
            remove-item -Path "$($ENVIRONMENT_ROOT_DIR)\conf\env_custom" -Force -confirm:$false
        }

    }

    # if 'env_custom' doesn't exist, create it
    if ( ! $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\conf\env_custom") ) {
        
        "# Add Custom variables here" | Out-File -FilePath "$($ENVIRONMENT_ROOT_DIR)\conf\env_custom" -Append -Encoding utf8
        "# Or, alternately, re-define and override default variables located in the env_default file" | Out-File -FilePath "$($ENVIRONMENT_ROOT_DIR)\conf\env_custom" -Append -Encoding utf8
    }

}

function generateDefaultEnvAppFile {

    param (
        $deleteFlag
    )

    # if argument '-reset' is passed, delete applications file
    if ( $deleteFlag -eq "reset" ) {

        if ( $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\conf\applications") ) {
            remove-item -Path "$($ENVIRONMENT_ROOT_DIR)\conf\applications" -Force -confirm:$false
        }

    }

    # if 'applications' doesn't exist, create it
    if ( ! $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\conf\applications") ) {
        
        "# Add required applications here, one per line" | Out-File -FilePath "$($ENVIRONMENT_ROOT_DIR)\conf\applications" -Append -Encoding utf8
        "# Available applications:" | Out-File -FilePath "$($ENVIRONMENT_ROOT_DIR)\conf\applications" -Append -Encoding utf8
        "#     nodejs" | Out-File -FilePath "$($ENVIRONMENT_ROOT_DIR)\conf\applications" -Append -Encoding utf8

    }


}

function generateDefaultEnvFile {

    param (
        $deleteFlag
    )

    # if argument '-reset' is passed, delete env_default file
    if ( $deleteFlag -eq "reset" ) {

        if ( $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\conf\env_default") ) {
            remove-item -Path "$($ENVIRONMENT_ROOT_DIR)\conf\env_default" -Force -confirm:$false
        }

    }

    # if 'env_default' doesn't exist, create it
    if ( ! $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\conf\env_default") ) {
        
        "# This file is auto-generated" | Out-File -FilePath "$($ENVIRONMENT_ROOT_DIR)\conf\env_default" -Append -Encoding utf8
        "# If you want to add/modify variables (or overwrite ones here), edit the 'env_custom' file" | Out-File -FilePath "$($ENVIRONMENT_ROOT_DIR)\conf\env_default" -Append -Encoding utf8

    }


}

function generateDefaultConfFolderStructure {
    param (
        $deleteFlag
    )

    if ( $deleteFlag -eq "reset" ) {

        if ( $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\conf") ) {
            remove-item -Path "$($ENVIRONMENT_ROOT_DIR)\conf" -Recurse -Force -confirm:$false
        }

    }

    if ( ! $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\conf") ) {
        New-Item -Path "$($ENVIRONMENT_ROOT_DIR)" -name "conf" -ItemType "directory"
    }


}

function generateDefaultBinFolderStructure {

    param (
        $deleteFlag
    )

    if ( $deleteFlag -eq "reset" ) {

        if ( $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\bin") ) {
            remove-item -Path "$($ENVIRONMENT_ROOT_DIR)\bin" -Recurse -Force -confirm:$false
        }

    }

    if ( ! $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\bin") ) {
        New-Item -Path "$($ENVIRONMENT_ROOT_DIR)" -name "bin" -ItemType "directory"
    }

    if ( ! $(test-path -Path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows") ) {
        New-Item -Path "$($ENVIRONMENT_ROOT_DIR)\bin" -name ".windows" -ItemType "directory"
    }


}

function resetEnvSetup {
    
    generateDefaultBinFolderStructure -deleteFlag "reset"
    generateDefaultConfFolderStructure -deleteFlag "reset"
    generateDefaultEnvCustomFile -deleteFlag "reset"
    generateDefaultEnvAppFile -deleteFlag "reset"
    generateDefaultEnvFile -deleteFlag "reset"

}

function shouldBeDeployed {

    param (
        $selectedApp
    )

    if ($null -eq $selectedApp) {
        write-host "please enter an app name"
        exit
    }

    generateDefaultEnvAppFile

    $allWantedApps = @()
    $allWantedAppsInit = Get-Content "$($ENVIRONMENT_ROOT_DIR)\conf\applications"

    foreach ( $wantedApp in $allWantedAppsInit ) {
        if ( ($wantedApp -notlike "#*") -and !($WantedApp -eq "") ) {
            $allWantedApps += $wantedApp.ToLower()
        }
    }

    $ourAppPresent = ($allWantedApps.Contains($selectedApp.ToLower()))

    if ($ourAppPresent) {
        return "yes"
    } else {
        return "no"
    }

}

function setupDefaultEnvironmentVariables {
    $packageModules = Get-ChildItem -Recurse -Path "$($ENVIRONMENT_ROOT_DIR)\lib\package_modules\windows"
    $packageVariables = ""

    $pathVariable = "$($ENVIRONMENT_ROOT_DIR)\bin\;$($Env:Path)"

    foreach ($module in $packageModules) {
        $packageVar = . $($module) -environmentVariableSetup environmentSetup
        if ($packageVariables -eq "") {
            $packageVariables="$($packageVar)"
        } else {
            $packageVariables="$($packageVariables) :: $($packageVar)"
        }
        
    }

    $variableArray = $packageVariables -split " :: "

    foreach ($element in $variableArray) {

        if ($element -like "*PATH=*") {
            
            $newPathEntry=$($element).replace("PATH=","")

            if ( !($pathVariable -like "*$($newPathEntry)*") ) {
                $pathVariable="$($pathVariable);$($newPathEntry)"
            }

        } else {
            $element | out-file "$($ENVIRONMENT_ROOT_DIR)\conf\env_default" -Append -Encoding utf8
        }
    }

    "PATH=$($pathVariable)" | out-file "$($ENVIRONMENT_ROOT_DIR)\conf\env_default" -Append -Encoding utf8
}

function applyDefaultEnvironmentVariables {
 
    $envDefaultContents = Get-Content "$($ENVIRONMENT_ROOT_DIR)\conf\env_default"
    $defaultEnvironmentVars = @()
    foreach ($line in $envDefaultContents) {
        if ( !($line -like "") -and !($line -like "#*") -and !($line -eq " ") ) {
            $defaultEnvironmentVars += $line
        }
    }

    foreach ($envVar in $defaultEnvironmentVars) {
        $varName = $($envVar -split "=")[0]
        $varValue = $($envVar -split "=")[1]

        [Environment]::SetEnvironmentVariable($varName, $varValue, [EnvironmentVariableTarget]::Process)

    }

}
$ENVIRONMENT_ROOT_DIR = $MyInvocation.MyCommand.Path
$ENVIRONMENT_ROOT_DIR = $ENVIRONMENT_ROOT_DIR.replace("\environment_functions.ps1","")

Set-Location $ENVIRONMENT_ROOT_DIR
set-location ..
set-location ..
set-location ..
$ENVIRONMENT_ROOT_DIR = get-location



function generateDefaultEnvCustomFile {

    param (
        $deleteFlag
    )

    # if argument '-reset' is passed, delete env_custom file
    if ( $deleteFlag -eq "reset" ) {

        if ( $(test-path -Path $ENVIRONMENT_ROOT_DIR/conf/env_custom) ) {
            remove-item -Path $ENVIRONMENT_ROOT_DIR/conf/env_custom -Force -confirm:$false
        }

    }

    # if 'env_custom' doesn't exist, create it
    if ( ! $(test-path -Path $ENVIRONMENT_ROOT_DIR/conf/env_custom) ) {
        
        "# Add Custom variables here" | Out-File -FilePath "$ENVIRONMENT_ROOT_DIR/conf/env_custom" -Append -Encoding utf8
        "# Or, alternately, re-define and override default variables located in the env_default file" | Out-File -FilePath "$ENVIRONMENT_ROOT_DIR/conf/env_custom" -Append -Encoding utf8
    }

}

function generateDefaultEnvAppFile {

    param (
        $deleteFlag
    )

    # if argument '-reset' is passed, delete applications file
    if ( $deleteFlag -eq "reset" ) {

        if ( $(test-path -Path $ENVIRONMENT_ROOT_DIR/conf/applications) ) {
            remove-item -Path $ENVIRONMENT_ROOT_DIR/conf/applications -Force -confirm:$false
        }

    }

    # if 'applications' doesn't exist, create it
    if ( ! $(test-path -Path $ENVIRONMENT_ROOT_DIR/conf/applications) ) {
        
        "# Add required applications here, one per line" | Out-File -FilePath "$ENVIRONMENT_ROOT_DIR/conf/applications" -Append -Encoding utf8
        "# Available applications:" | Out-File -FilePath "$ENVIRONMENT_ROOT_DIR/conf/applications" -Append -Encoding utf8
        "#     nodejs" | Out-File -FilePath "$ENVIRONMENT_ROOT_DIR/conf/applications" -Append -Encoding utf8

    }


}

function generateDefaultEnvFile {

    param (
        $deleteFlag
    )

    # if argument '-reset' is passed, delete env_default file
    if ( $deleteFlag -eq "reset" ) {

        if ( $(test-path -Path $ENVIRONMENT_ROOT_DIR/conf/env_default) ) {
            remove-item -Path $ENVIRONMENT_ROOT_DIR/conf/env_default -Force -confirm:$false
        }

    }

    # if 'env_default' doesn't exist, create it
    if ( ! $(test-path -Path $ENVIRONMENT_ROOT_DIR/conf/env_default) ) {
        
        "# This file is auto-generated" | Out-File -FilePath "$ENVIRONMENT_ROOT_DIR/conf/env_default" -Append -Encoding utf8
        "# If you want to add/modify variables (or overwrite ones here), edit the 'env_custom' file" | Out-File -FilePath "$ENVIRONMENT_ROOT_DIR/conf/env_default" -Append -Encoding utf8

    }


}

function generateDefaultConfFolderStructure {
    param (
        $deleteFlag
    )

    if ( $deleteFlag -eq "reset" ) {

        if ( $(test-path -Path $ENVIRONMENT_ROOT_DIR/conf) ) {
            remove-item -Path $ENVIRONMENT_ROOT_DIR/conf -Recurse -Force -confirm:$false
        }

    }

    if ( ! $(test-path -Path $ENVIRONMENT_ROOT_DIR/conf) ) {
        New-Item -Path "$ENVIRONMENT_ROOT_DIR" -name "conf" -ItemType "directory"
    }


}

function generateDefaultBinFolderStructure {

    param (
        $deleteFlag
    )

    if ( $deleteFlag -eq "reset" ) {

        if ( $(test-path -Path $ENVIRONMENT_ROOT_DIR/bin) ) {
            remove-item -Path $ENVIRONMENT_ROOT_DIR/bin -Recurse -Force -confirm:$false
        }

    }

    if ( ! $(test-path -Path $ENVIRONMENT_ROOT_DIR/bin) ) {
        New-Item -Path "$ENVIRONMENT_ROOT_DIR" -name "bin" -ItemType "directory"
    }

    if ( ! $(test-path -Path "$ENVIRONMENT_ROOT_DIR/bin/.windows") ) {
        New-Item -Path "$ENVIRONMENT_ROOT_DIR/bin" -name ".windows" -ItemType "directory"
    }


}

function deployStandardToolCurl {
    write-host "new"
}

function deployStandardToolUnzip {
    write-host "new"
}

function resetEnvSetup {
    
    generateDefaultBinFolderStructure -deleteFlag "reset"
    generateDefaultConfFolderStructure -deleteFlag "reset"
    generateDefaultEnvCustomFile -deleteFlag "reset"
    generateDefaultEnvAppFile -deleteFlag "reset"
    generateDefaultEnvFile -deleteFlag "reset"
    deployStandardToolCurl
    deployStandardToolUnzip

}
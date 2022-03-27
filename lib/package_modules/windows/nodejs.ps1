param (
    $environmentVariableSetup = $false
)
$ENVIRONMENT_ROOT_DIR = $MyInvocation.MyCommand.Path
$ENVIRONMENT_ROOT_DIR = $ENVIRONMENT_ROOT_DIR.replace("\nodejs.ps1","")

Set-Location $ENVIRONMENT_ROOT_DIR
set-location ..
set-location ..
set-location ..
$ENVIRONMENT_ROOT_DIR = get-location
. $ENVIRONMENT_ROOT_DIR\lib\functions\windows\environment_functions.ps1



function makePackageFolderStructure {

    if ( !(test-path -path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node") ) {
        New-Item -Path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows" -name ".node" -ItemType "directory"
    }

}

function getPackageVersionFromWeb {

    param (
        $formatType
    )

    $latestVersion = Invoke-RestMethod -Method "get" -Uri "https://nodejs.org/dist/latest" -UseBasicParsing
    $latestVersion = $latestVersion -split '<a href="' -split '">' | Where-Object {$_ -like "*-win-x64.zip"}

    switch ($formatType) {
        "downloadUrl" {
            $latestVersionUrl="https://nodejs.org/dist/latest/$($latestVersion)"
            return $latestVersionUrl
        }
        "zipFileName" {
            return $latestVersion
        }
        "cacheNameLocally" {
            makePackageFolderStructure
            $latestVersion | Out-File "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\.downloaded_version_number" -Encoding utf8
            return $latestVersion
        }
        default {
            $latestVersionName = $latestVersion -replace ".zip",""
            return $latestVersionName
        }
    }
}

function getCachedVersion {

    if (test-path -Path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\.downloaded_version_number") {
        return $(Get-Content -Path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\.downloaded_version_number" )
    } else {
        return ""
    }
}

function isPackageAlreadyDeployed {

    makePackageFolderStructure
    $cachedVersionName = $(getCachedVersion).replace(".zip","")

    if ($cachedVersionName -eq "" ) {
        return "no"
    }

    if (test-path -Path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($cachedVersionName)\node.exe") {
        return "yes"
    } else {
        return "no"
    }
}

function isPackageAtLatestVersion {

    makePackageFolderStructure
    $cachedVersionName = getCachedVersion
    $latestVersionNameFromWeb = getPackageVersionFromWeb -formatType "zipFileName"

    if ($cachedVersionName -eq $latestVersionNameFromWeb) {
        $deployedAlready = isPackageAlreadyDeployed

        if  ($deployedAlready -eq "yes" ) {
            return "yes"
        } else {
            return "no"
        }
    } else {
        return "no"
    }

}

function ensureSymLinksExist {

    $versionName=$(getCachedVersion).replace(".zip","")

    if ( test-path -Path "$($ENVIRONMENT_ROOT_DIR)\bin\node.exe") {
        Remove-Item "$($ENVIRONMENT_ROOT_DIR)\bin\node.exe" -Confirm:$false -Force
    }

    New-Item -ItemType HardLink -Path "$($ENVIRONMENT_ROOT_DIR)\bin\node.exe"  -Target "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($versionName)\node.exe"


    if ( test-path -Path "$($ENVIRONMENT_ROOT_DIR)\bin\npm.cmd") {
        Remove-Item "$($ENVIRONMENT_ROOT_DIR)\bin\npm.cmd" -Confirm:$false -Force
    }

    $npmContents = Get-Content "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($versionName)\npm.cmd"
    $npmContents = $npmContents -replace "%~dp0","$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($versionName)"
    $npmContents | Out-File "$($ENVIRONMENT_ROOT_DIR)\bin\npm.cmd" -Encoding ascii


    if ( test-path -Path "$($ENVIRONMENT_ROOT_DIR)\bin\npx.cmd") {
        Remove-Item "$($ENVIRONMENT_ROOT_DIR)\bin\npx.cmd" -Confirm:$false -Force
    }

    $npxContents = Get-Content "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($versionName)\npx.cmd"
    $npxContents = $npmContents -replace "%~dp0","$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($versionName)"
    $npxContents | Out-File "$($ENVIRONMENT_ROOT_DIR)\bin\npx.cmd" -Encoding ascii
}

function installPackage {
    write-host "** nodejs needs installing **"

    $latestVersionUrlFromWeb = getPackageVersionFromWeb -formatType "cacheNameLocally"
    $latestDownloadUrlFromWeb = getPackageVersionFromWeb -formatType "downloadUrl"

    Invoke-WebRequest -Uri $latestDownloadUrlFromWeb -Method "get" -OutFile "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($latestVersionUrlFromWeb)"

    if (test-path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($latestVersionUrlFromWeb)" ) {
        unzip "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($latestVersionUrlFromWeb)" "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\"
    }
}

$deployNode = shouldBeDeployed -selectedApp "nodejs"

if ($deployNode -eq "yes") {

    if ( $environmentVariableSetup -eq "environmentSetup") {
        return "PATH=$($ENVIRONMENT_ROOT_DIR)\bin\"
    }

    makePackageFolderStructure
    $isPackageDeployed = isPackageAlreadyDeployed
    $isPackageLatestVersioninstalled = isPackageAtLatestVersion

    if ($isPackageDeployed -eq "no") {
        installPackage
    }

    if ( ($isPackageDeployed -eq "yes") -and ($isPackageLatestVersioninstalled -eq "no") ) {

        $installDirective = read-Host "nodejs has a new version. Upgrade? [y/n]"
        switch ($installDirective) {
            "y"{installPackage}
            default {write-host "** skipping node upgrade **"}
        }

    }

    ensureSymLinksExist

}
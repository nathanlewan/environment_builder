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



function makeNodeJsFolderStructure {

    if ( !(test-path -path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node") ) {
        New-Item -Path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows" -name ".node" -ItemType "directory"
    }

}

function getNodeVersionFromWeb {

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
            makeNodeJsFolderStructure
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
    }
}

function isNodeAlreadyDeployed {

    makeNodeJsFolderStructure
    $cachedVersionName = getCachedVersion
    $latestVersionNameFromWeb = getNodeVersionFromWeb

    if ($cachedVersionName -eq "" ) {
        return "no"
    }

    if (test-path -Path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($latestVersionNameFromWeb)\node.exe") {
        return "yes"
    } else {
        return "no"
    }
}

function isNodeAtLatestVersion {

    makeNodeJsFolderStructure
    $cachedVersionName = getCachedVersion
    $latestVersionNameFromWeb = getNodeVersionFromWeb -formatType "zipFileName"

    if ($cachedVersionName -eq $latestVersionNameFromWeb) {
        $deployedAlready = isNodeAlreadyDeployed

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

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$($ENVIRONMENT_ROOT_DIR)\bin\node.lnk")
    $Shortcut.TargetPath = "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\node-v17.7.2-win-x64\node.exe"
    $Shortcut.Save()

}

$deployNode = shouldBeDeployed -selectedApp "nodejs"

if ($deployNode -eq "yes") {

    if ( $environmentVariableSetup -eq "environmentSetup") {
        return "PATH=$($ENVIRONMENT_ROOT_DIR)\bin"
    }

    makeNodeJsFolderStructure
    $isNodeDeployed = isNodeAlreadyDeployed
    $isNodeLatestVersioninstalled = isNodeAtLatestVersion

    if ( ($isNodeDeployed -eq "no") -or ($isNodeLatestVersioninstalled -eq "no") ) {

        write-host "needs installing"

        $latestVersionUrlFromWeb = getNodeVersionFromWeb -formatType "cacheNameLocally"
        $latestDownloadUrlFromWeb = getNodeVersionFromWeb -formatType "downloadUrl"

        Invoke-WebRequest -Uri $latestDownloadUrlFromWeb -Method "get" -OutFile "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($latestVersionUrlFromWeb)"

        if (test-path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($latestVersionUrlFromWeb)" ) {
            Expand-Archive -path "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\$($latestVersionUrlFromWeb)" -DestinationPath "$($ENVIRONMENT_ROOT_DIR)\bin\.windows\.node\" -confirm:$false -Force
        }
    }

    ensureSymLinksExist

}
#!/bin/bash
ENVIRONMENT_ROOT_DIR=$(echo "${BASH_SOURCE[0]}" | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}')
cd "$ENVIRONMENT_ROOT_DIR" || exit
cd ..
cd ..
cd ..
ENVIRONMENT_ROOT_DIR=$(pwd)
source "$ENVIRONMENT_ROOT_DIR"/lib/functions/linux/environment_functions.sh
environmentVariableSetup=$1





makePackageFolderStructure () {

    if [ ! -d "$ENVIRONMENT_ROOT_DIR/bin/.linux/.node" ]
    then
        mkdir "$ENVIRONMENT_ROOT_DIR/bin/.linux/.node"
    fi

}

getPackageVersionFromWeb () {

    # first argument passed to function
    formatType=$1

    # if argument '-reset' is passed, delete env_custom file
    latestVersionPackageName=$("$ENVIRONMENT_ROOT_DIR"/bin/curl --no-progress-meter https://nodejs.org/dist/latest-gallium/ | grep linux | grep x64 | grep tar.gz | awk -F "=" '{print $2}' | awk -F "</a>" '{print $1}' | awk -F ">" '{print $2}')

    case $formatType in

        "-downloadUrl")
            # example return: "https://nodejs.org/dist/latest/node-v*.*.*-linux-x64.tar.gz"
            latestVersionUrl="https://nodejs.org/dist/latest-gallium/$latestVersionPackageName"
            echo "$latestVersionUrl"
        ;;
        "-packageFileName")
            # example return: "node-v*.*.*-linux-x64.tar.gz"
            echo "$latestVersionPackageName"
        ;;
        "-cachePackageFileNameLocallyAndReturn")
            # example return: "node-v*.*.*-linux-x64.tar.gz"
            makePackageFolderStructure
            echo "$latestVersionPackageName" > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/.downloaded_version_number
            echo "$latestVersionPackageName"
        ;;
        *)
            # example return: "node-v*.*.*-linux-x64"
            latestVersionFolderName=${latestVersionPackageName//.tar.gz/}
            echo "$latestVersionFolderName"
        ;;

    esac

}

getCachedVersion () {

    if [ ! -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/.downloaded_version_number ]
    then
        echo ""
    else
        thisVersion=$(cat "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/.downloaded_version_number)
        echo "$thisVersion"
    fi

}

isPackageAlreadyDeployed () {

    makePackageFolderStructure
    cachedVersionName=$(getCachedVersion | sed -e 's/.tar.gz//g')

    if [ "$cachedVersionName" == "" ]
    then
        echo "no"
        return
    fi

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$cachedVersionName"/bin/node ]
    then
        echo "yes"
    else
        echo "no"
    fi

}

isPackageAtLatestVersion () {

    makePackageFolderStructure
    cachedVersionName=$(getCachedVersion)
    latestVersionNameFromWeb=$(getPackageVersionFromWeb -packageFileName)

    if [ "$cachedVersionName" == "$latestVersionNameFromWeb" ]
    then
        deployedAlready=$(isPackageAlreadyDeployed)

        if [ "$deployedAlready" == "yes" ]
        then
            echo "yes"
        else
            echo "no"
        fi
    else
        echo "no"
    fi

}

ensureSymLinksExist () {

    versionName=$(getCachedVersion | sed -e 's/.tar.gz//g')

    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/node ]
    then
        unlink "$ENVIRONMENT_ROOT_DIR"/bin/node
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$versionName"/bin/node "$ENVIRONMENT_ROOT_DIR"/bin/node
    else
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$versionName"/bin/node "$ENVIRONMENT_ROOT_DIR"/bin/node
    fi

    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/npm ]
    then
        unlink "$ENVIRONMENT_ROOT_DIR"/bin/npm
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$versionName"/bin/npm "$ENVIRONMENT_ROOT_DIR"/bin/npm
    else
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$versionName"/bin/npm "$ENVIRONMENT_ROOT_DIR"/bin/npm
    fi

    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/npx ]
    then
        unlink "$ENVIRONMENT_ROOT_DIR"/bin/npx 
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$versionName"/bin/npx "$ENVIRONMENT_ROOT_DIR"/bin/npx
    else
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$versionName"/bin/npx "$ENVIRONMENT_ROOT_DIR"/bin/npx
    fi
}

installPackage () {
    consoleLog "nodejs needs installing" "SUCCESS" 0

    latestVersionUrlFromWeb=$(getPackageVersionFromWeb -cachePackageFileNameLocallyAndReturn)
    latestDownloadUrlFromWeb=$(getPackageVersionFromWeb -downloadUrl)
    "$ENVIRONMENT_ROOT_DIR"/bin/curl "$latestDownloadUrlFromWeb" > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$latestVersionUrlFromWeb"

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$latestVersionUrlFromWeb" ]
    then
        tar x -C "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$latestVersionUrlFromWeb"
    else
        consoleLog "error: nodejs tarball not downloaded" "FAIL" 1
    fi
}




deployPackage=$(shouldBeDeployed nodejs)

if [ "$deployPackage" == "yes" ]
then

    case $environmentVariableSetup in

        "-environmentSetup")
            echo "export PATH=$ENVIRONMENT_ROOT_DIR/bin"
        ;;
        *)

            makePackageFolderStructure
            isPackageDeployed=$(isPackageAlreadyDeployed)
            isPackageLatestVersionInstalled=$(isPackageAtLatestVersion)

            if [ "$isPackageDeployed" == "no" ]
            then
                installPackage
            fi

            if [ "$isPackageDeployed" == "yes" ] && [ "$isPackageLatestVersionInstalled" == "no" ]
            then

                read -r -t 5 -p 'nodejs has a new version. Upgrade? (timeout to no in 5 seconds) [y/n]: ' installDirective

                case $installDirective in

                    "y"|"Y")
                        installPackage
                    ;;
                    "n"|"N")
                        consoleLog "skipping node upgrade" "SUCCESS" 1
                    ;;
                    *)
                        consoleLog "skipping node upgrade" "SUCCESS" 1
                    ;;

                esac

            fi

            ensureSymLinksExist
        ;;
    esac
    
fi


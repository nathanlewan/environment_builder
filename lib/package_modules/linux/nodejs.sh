#!/bin/bash
ENVIRONMENT_ROOT_DIR=$(echo "${BASH_SOURCE[0]}" | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}')
cd "$ENVIRONMENT_ROOT_DIR" || exit
cd ..
cd ..
cd ..
ENVIRONMENT_ROOT_DIR=$(pwd)
source "$ENVIRONMENT_ROOT_DIR"/lib/functions/linux/environment_functions.sh
environmentVariableSetup=$1





makeNodeJsFolderStructure () {

    if [ ! -d "$ENVIRONMENT_ROOT_DIR/bin/.linux/.node" ]
    then
        mkdir "$ENVIRONMENT_ROOT_DIR/bin/.linux/.node"
    fi

}

getNodeVersionFromWeb () {

    # first argument passed to function
    formatType=$1

    # if argument '-reset' is passed, delete env_custom file
    latestVersion=$(curl --no-progress-meter https://nodejs.org/dist/latest/ | grep linux | grep x64 | grep tar.gz | awk -F "=" '{print $2}' | awk -F "</a>" '{print $1}' | awk -F ">" '{print $2}')

    case $formatType in

        "-downloadUrl")
            latestVersionUrl="https://nodejs.org/dist/latest/$latestVersion"
            echo "$latestVersionUrl"
        ;;
        "-tarballName")
            echo "$latestVersion"
        ;;
        "-cacheNameLocally")
            makeNodeJsFolderStructure
            echo "$latestVersion" > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/.downloaded_version_number
            echo "$latestVersion"
        ;;
        *)
            latestVersionName=${latestVersion//.tar.gz/}
            echo "$latestVersionName"
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

isNodeAlreadyDeployed () {

    makeNodeJsFolderStructure
    cachedVersionName=$(getCachedVersion)
    latestVersionNameFromWeb=$(getNodeVersionFromWeb)

    if [ "$cachedVersionName" == "" ]
    then
        echo "no"
        return
    fi

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$latestVersionNameFromWeb"/bin/node ]
    then
        echo "yes"
    else
        echo "no"
    fi

}

isNodeAtLatestVersion () {

    makeNodeJsFolderStructure
    cachedVersionName=$(getCachedVersion)
    latestVersionNameFromWeb=$(getNodeVersionFromWeb -tarballName)

    if [ "$cachedVersionName" == "$latestVersionNameFromWeb" ]
    then
        deployedAlready=$(isNodeAlreadyDeployed)

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





deployNode=$(shouldBeDeployed nodejs)

if [ "$deployNode" == "yes" ]
then

    case $environmentVariableSetup in

        "-environmentSetup")
            echo "PATH=$ENVIRONMENT_ROOT_DIR/bin"
        ;;
        *)

            makeNodeJsFolderStructure
            isNodeDeployed=$(isNodeAlreadyDeployed)
            isNodeLatestVersionInstalled=$(isNodeAtLatestVersion)

            if [ "$isNodeDeployed" == "no" ] || [ "$isNodeLatestVersionInstalled" == "no" ]
            then
                echo "needs installing"
                latestVersionUrlFromWeb=$(getNodeVersionFromWeb -cacheNameLocally)
                latestDownloadUrlFromWeb=$(getNodeVersionFromWeb -downloadUrl)
                curl "$latestDownloadUrlFromWeb" > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$latestVersionUrlFromWeb"

                if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$latestVersionUrlFromWeb" ]
                then
                    tar xv -C "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.node/"$latestVersionUrlFromWeb"
                else
                    echo "error: nodejs tarball not downloaded"
                fi

            fi

            ensureSymLinksExist

        esac
    
fi


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

    if [ ! -d "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast" ]
    then
        mkdir "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast"
    fi

}

getPackageVersionFromWeb () {

    # first argument passed to function
    formatType=$1

    # if argument '-reset' is passed, delete env_custom file
    latestVersionPackageName="hazelcast-5.0.2-slim.tar.gz"

    case $formatType in

        "-downloadUrl")
            # example return: "https://nodejs.org/dist/latest/node-v*.*.*-linux-x64.tar.gz"
            latestVersionUrl="https://github.com/hazelcast/hazelcast/releases/download/v5.0.2/$latestVersionPackageName"
            echo "$latestVersionUrl"
        ;;
        "-packageFileName")
            # example return: "node-v*.*.*-linux-x64.tar.gz"
            echo "$latestVersionPackageName"
        ;;
        "-cachePackageFileNameLocallyAndReturn")
            # example return: "node-v*.*.*-linux-x64.tar.gz"
            makePackageFolderStructure
            echo "$latestVersionPackageName" > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/.downloaded_version_number
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

    if [ ! -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/.downloaded_version_number ]
    then
        echo ""
    else
        thisVersion=$(cat "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/.downloaded_version_number)
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

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/"$cachedVersionName"/lib/hazelcast-5.0.2.jar ]
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

    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast ]
    then
        unlink "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/"$versionName"/bin/hz-start "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast
    else
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/"$versionName"/bin/hz-start "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast
    fi

}

installPackage () {
    echo "** hazelcast needs installing **"
    latestVersionUrlFromWeb=$(getPackageVersionFromWeb -cachePackageFileNameLocallyAndReturn)
    latestDownloadUrlFromWeb=$(getPackageVersionFromWeb -downloadUrl)
    echo "$ENVIRONMENT_ROOT_DIR/bin/curl $latestDownloadUrlFromWeb"
    "$ENVIRONMENT_ROOT_DIR"/bin/curl "$latestDownloadUrlFromWeb" -L > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/"$latestVersionUrlFromWeb"

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/"$latestVersionUrlFromWeb" ]
    then
        tar xv -C "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/"$latestVersionUrlFromWeb"
    else
        echo "error: hazelcast tarball not downloaded"
    fi
}




deployPackage=$(shouldBeDeployed hazelcast)

if [ "$deployPackage" == "yes" ]
then

    case $environmentVariableSetup in

        "-environmentSetup")
            echo "HAZELCAST_HOME=$ENVIRONMENT_ROOT_DIR/bin"
            echo "CLASSPATH=$CLASSPATH:$ENVIRONMENT_ROOT_DIR/bin/$HAZELCAST_HOME/hazelcast.jar"
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

                read -r -t 5 -p 'hazelcast has a new version. Upgrade? (timeout to no in 5 seconds) [y/n]: ' installDirective

                case $installDirective in

                    "y"|"Y")
                        installPackage
                    ;;
                    "n"|"N")
                        echo "** skipping hazelcast upgrade **"
                    ;;
                    *)
                        echo "** skipping hazelcast upgrade **"
                    ;;

                esac

            fi

            ensureSymLinksExist
        ;;
    esac
    
fi


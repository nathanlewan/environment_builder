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

    if [ ! -d "$ENVIRONMENT_ROOT_DIR/bin/.linux/.java" ]
    then
        mkdir "$ENVIRONMENT_ROOT_DIR/bin/.linux/.java"
    fi

}

getPackageVersionFromWeb () {

    # first argument passed to function
    formatType=$1

    latestVersionPackageName="openjdk-11.0.2_linux-x64_bin.tar.gz"

    # only needed in some instances
    latestVersionPackageSubFolderName="jdk-11.0.2"

    case $formatType in

        "-downloadUrl")
            # example return: "https://download.java.net/java/GA/jdk*/*/GPL/openjdk-*.*.*_linux-x64_bin.tar.gz"
            latestVersionUrl="https://download.java.net/java/GA/jdk11/9/GPL/$latestVersionPackageName"
            echo "$latestVersionUrl"
        ;;
        "-packageFileName")
            # example return: "openjdk-*.*.*_linux-x64_bin.tar.gz"
            echo "$latestVersionPackageName"
        ;;
        "-packageSubFolderName")
            # example return: "openjdk-*.*.*_linux-x64_bin.tar.gz"
            echo "$latestVersionPackageSubFolderName"
        ;;
        "-cachePackageFileNameLocallyAndReturn")
            # example return: "openjdk-*.*.*_linux-x64_bin.tar.gz"
            makePackageFolderStructure
            echo "$latestVersionPackageName" > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/.downloaded_version_number
            echo "$latestVersionPackageName"
        ;;
        *)
            # example return: "openjdk-*.*.*_linux-x64_bin"
            latestVersionFolderName=${latestVersionPackageName//.tar.gz/}
            echo "$latestVersionFolderName"
        ;;

    esac

}

getCachedVersion () {

    if [ ! -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/.downloaded_version_number ]
    then
        echo ""
    else
        thisVersion=$(cat "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/.downloaded_version_number)
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

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$latestVersionPackageSubFolderName"/bin/java ]
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

    versionName=$(getPackageVersionFromWeb -packageSubFolderName)

    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/java ]
    then
        unlink "$ENVIRONMENT_ROOT_DIR"/bin/java
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$versionName"/bin/java "$ENVIRONMENT_ROOT_DIR"/bin/java
    else
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$versionName"/bin/java "$ENVIRONMENT_ROOT_DIR"/bin/java
    fi

}

installPackage () {
    echo "** java openjdk needs installing **"
    latestVersionUrlFromWeb=$(getPackageVersionFromWeb -cachePackageFileNameLocallyAndReturn)
    latestDownloadUrlFromWeb=$(getPackageVersionFromWeb -downloadUrl)
    "$ENVIRONMENT_ROOT_DIR"/bin/curl "$latestDownloadUrlFromWeb" > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$latestVersionUrlFromWeb"

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$latestVersionUrlFromWeb" ]
    then
        tar xv -C "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$latestVersionUrlFromWeb"
    else
        echo "error: openjdk tarball not downloaded"
    fi
}




deployPackage=$(shouldBeDeployed java)

if [ "$deployPackage" == "yes" ]
then

    case $environmentVariableSetup in

        "-environmentSetup")
            echo "PATH=$ENVIRONMENT_ROOT_DIR/bin"
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

                read -r -t 5 -p 'openjdk has a new version. Upgrade? (timeout to no in 5 seconds) [y/n]: ' installDirective

                case $installDirective in

                    "y"|"Y")
                        installPackage
                    ;;
                    "n"|"N")
                        echo "** skipping node upgrade **"
                    ;;
                    *)
                        echo "** skipping node upgrade **"
                    ;;

                esac

            fi

            ensureSymLinksExist
        ;;
    esac
    
fi


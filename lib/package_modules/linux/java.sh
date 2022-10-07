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
            # example return: "jdk-*.*.*", used as name for uncompressed folder
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
    subFolderName=$(getPackageVersionFromWeb -packageSubFolderName)

    if [ "$cachedVersionName" == "" ]
    then
        echo "no"
        return
    fi

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$subFolderName"/bin/java ]
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

    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/keytool ]
    then
        unlink "$ENVIRONMENT_ROOT_DIR"/bin/keytool
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$versionName"/bin/keytool "$ENVIRONMENT_ROOT_DIR"/bin/keytool
    else
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$versionName"/bin/keytool "$ENVIRONMENT_ROOT_DIR"/bin/keytool
    fi

}

installPackage () {
    consoleLog "java openjdk needs installing" "SUCCESS" 0

    latestVersionUrlFromWeb=$(getPackageVersionFromWeb -cachePackageFileNameLocallyAndReturn)
    latestDownloadUrlFromWeb=$(getPackageVersionFromWeb -downloadUrl)
    "$ENVIRONMENT_ROOT_DIR"/bin/curl "$latestDownloadUrlFromWeb" > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$latestVersionUrlFromWeb"

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$latestVersionUrlFromWeb" ]
    then
        tar x -C "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.java/"$latestVersionUrlFromWeb"
    else
        consoleLog "error: openjdk tarball not downloaded" "FAIL" 1
    fi
}

setDefaultEnvironmentInfo () {
    versionName=$(getPackageVersionFromWeb -packageSubFolderName)

    testPresence=`cat "$ENVIRONMENT_ROOT_DIR"/conf/env_default | grep -c -m 1 JAVA_HOME`
    if [ "$testPresence" == "0" ]
    then
        echo "export JAVA_HOME=$ENVIRONMENT_ROOT_DIR/bin/.linux/.java/$versionName" >> "$ENVIRONMENT_ROOT_DIR"/conf/env_default
    fi

    testPresence=`cat "$ENVIRONMENT_ROOT_DIR"/conf/env_default | grep -c -m 1 JAVA_KEYSTORE`
    if [ "$testPresence" == "0" ]
    then
        echo "export JAVA_KEYSTORE=$ENVIRONMENT_ROOT_DIR/bin/.linux/.java/$versionName/lib/security/cacerts" >> "$ENVIRONMENT_ROOT_DIR"/conf/env_default
    fi
}




deployPackage=$(shouldBeDeployed java)

if [ "$deployPackage" == "yes" ]
then

    case $environmentVariableSetup in

        "-environmentSetup")
            setDefaultEnvironmentInfo
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


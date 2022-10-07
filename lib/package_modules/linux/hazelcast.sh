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


buildStopHazelcast () {

    # $1 = LatestHazelcastVersion

    if [ -f "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast/stop_hazelcast.sh" ]
    then
        rm -rf "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast/stop_hazelcast.sh"
    fi

    {

        echo "#!/bin/bash"
        echo " "
        echo "ENVIRONMENT_ROOT_DIR=\"$2\""
        echo "cd \"\$ENVIRONMENT_ROOT_DIR\" || exit"

        echo " "

        echo "ENVIRONMENT_ROOT_DIR=\$(pwd)"
        echo "source \"\$ENVIRONMENT_ROOT_DIR\"/lib/functions/linux/environment_functions.sh"

        echo " "

        echo "consoleLog 'Stopping Hazelcast' 'SUCCESS' 0"
        echo "latestName=\"$1\""
        echo "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast/\$latestName/bin/hz-stop"

        echo " "

        echo "pidCheck=\`ps ax | grep java | grep .linux/.hazelcast/\$latestName | awk '{print \$1}'\`"

        echo " "

        echo "if [ \"\$pidCheck\" == \"\" ]"
        echo "then"
        echo "    consoleLog 'Hazelcast not running' 'SUCCESS' 1"
        echo "else"
        echo "    kill \$pidCheck"
        echo "    sleep 2"
        echo "    kill \$pidCheck 2> /dev/null"
        echo "    consoleLog 'Hazelcast stopped' 'SUCCESS' 1"
        echo "fi"

    } >> "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast/stop_hazelcast.sh"

    chmod 755 "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast/stop_hazelcast.sh"

}

buildStartHazelcast () {

    # $1 = LatestHazelcastVersion

    if [ -f "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast/start_hazelcast.sh" ]
    then
        rm -rf "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast/start_hazelcast.sh"
    fi

    {

        echo "#!/bin/bash"
        echo " "
        echo "ENVIRONMENT_ROOT_DIR=\"$2\""
        echo "cd \"\$ENVIRONMENT_ROOT_DIR\" || exit"

        echo " "

        echo "ENVIRONMENT_ROOT_DIR=\$(pwd)"
        echo "source \"\$ENVIRONMENT_ROOT_DIR\"/lib/functions/linux/environment_functions.sh"

        echo " "

        echo "consoleLog 'Starting Hazelcast' 'SUCCESS' 0"

        echo " "

        echo "latestName=\"$1\""
        echo " "

        echo "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast/\$latestName/bin/hz-start -d"



    } >> "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast/start_hazelcast.sh"

    chmod 755 "$ENVIRONMENT_ROOT_DIR/bin/.linux/.hazelcast/start_hazelcast.sh"

}



ensureSymLinksExist () {

    versionName=$(getCachedVersion | sed -e 's/.tar.gz//g')


    buildStopHazelcast "$versionName" "$ENVIRONMENT_ROOT_DIR"
    buildStartHazelcast "$versionName" "$ENVIRONMENT_ROOT_DIR"

    # cleanup from previous versions
    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast ]
        then
            unlink "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast
    fi

    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast_start ]
    then
        unlink "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast_start
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/start_hazelcast.sh "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast_start
    else
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/start_hazelcast.sh "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast_start
    fi

    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast_stop ]
    then
        unlink "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast_stop
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/stop_hazelcast.sh "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast_stop
    else
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/stop_hazelcast.sh "$ENVIRONMENT_ROOT_DIR"/bin/hazelcast_stop
    fi

}

installPackage () {
    consoleLog "hazelcast needs installing" "SUCCESS" 0

    latestVersionUrlFromWeb=$(getPackageVersionFromWeb -cachePackageFileNameLocallyAndReturn)
    latestDownloadUrlFromWeb=$(getPackageVersionFromWeb -downloadUrl)
    "$ENVIRONMENT_ROOT_DIR"/bin/curl "$latestDownloadUrlFromWeb" -L > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/"$latestVersionUrlFromWeb"

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/"$latestVersionUrlFromWeb" ]
    then
        tar x -C "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.hazelcast/"$latestVersionUrlFromWeb"
    else
        consoleLog "error: hazelcast tarball not downloaded" "FAIL" 1
    fi
}




deployPackage=$(shouldBeDeployed hazelcast)

if [ "$deployPackage" == "yes" ]
then

    case $environmentVariableSetup in

        "-environmentSetup")
            if [ "$CLASSPATH" == "" ]
            then
                echo "export HAZELCAST_HOME=$ENVIRONMENT_ROOT_DIR/bin :: export CLASSPATH=$ENVIRONMENT_ROOT_DIR/bin/hazelcast.jar"
            else
                echo "export HAZELCAST_HOME=$ENVIRONMENT_ROOT_DIR/bin :: export CLASSPATH=$CLASSPATH:$ENVIRONMENT_ROOT_DIR/bin/hazelcast.jar"
            fi
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
                        consoleLog "skipping hazelcast upgrade" "SUCCESS" 0
                    ;;
                    *)
                        consoleLog "skipping hazelcast upgrade" "SUCCESS" 0
                    ;;

                esac

            fi

            ensureSymLinksExist
        ;;
    esac
    
fi


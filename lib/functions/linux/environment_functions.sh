#!/bin/bash
ENVIRONMENT_ROOT_DIR=$(echo "${BASH_SOURCE[0]}" | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}')
cd "$ENVIRONMENT_ROOT_DIR" || exit
cd ..
cd ..
cd ..
ENVIRONMENT_ROOT_DIR=$(pwd)




generateDefaultEnvCustomFile () {

    # first argument passed to function
    deleteFlag=$1

    # if argument '-reset' is passed, delete env_custom file
    if [ "$deleteFlag" == "-reset" ]
    then
        if [ -f "$ENVIRONMENT_ROOT_DIR/conf/env_custom" ]
        then
            rm -f "$ENVIRONMENT_ROOT_DIR/conf/env_custom"
        fi
    fi

    # if 'env_custom' doesn't exist, create it
    if [ ! -f "$ENVIRONMENT_ROOT_DIR/conf/env_custom" ]
    then
        touch "$ENVIRONMENT_ROOT_DIR/conf/env_custom"
        echo "# Add Custom variables here" >> "$ENVIRONMENT_ROOT_DIR/conf/env_custom"
        echo "# Or, alternately, re-define and override default variables located in the env_default file" >> "$ENVIRONMENT_ROOT_DIR/conf/env_custom"
    fi

}

generateDefaultEnvAppFile () {

    # first argument passed to function
    deleteFlag=$1

    # if argument '-reset' is passed, delete applications file
    if [ "$deleteFlag" == "-reset" ]
    then
        if [ -f "$ENVIRONMENT_ROOT_DIR/conf/applications" ]
        then
            rm -f "$ENVIRONMENT_ROOT_DIR/conf/applications"
        fi
    fi

    # if 'applications' doesn't exist, create it
    if [ ! -f "$ENVIRONMENT_ROOT_DIR/conf/applications" ]
    then
        touch "$ENVIRONMENT_ROOT_DIR/conf/applications"

        {
            echo "# Add required applications here, one per line"
            echo "# Available applications:" 
            echo "#     * nodejs"
            echo "#     * java"
            echo "#     * hazelcast"
            echo "#     * tomcat"
        } >> "$ENVIRONMENT_ROOT_DIR/conf/applications"
 
    fi

}

generateDefaultEnvFile () {

    # first argument passed to function
    deleteFlag=$1

    # if argument '-reset' is passed, delete applications file
    if [ "$deleteFlag" == "-reset" ]
    then
        if [ -f "$ENVIRONMENT_ROOT_DIR/conf/env_default" ]
        then
            rm -f "$ENVIRONMENT_ROOT_DIR/conf/env_default"
        fi
    fi

    # if 'env_default' doesn't exist, create it
    if [ ! -f "$ENVIRONMENT_ROOT_DIR/conf/env_default" ]
    then
        touch "$ENVIRONMENT_ROOT_DIR/conf/env_default"
        echo "# This file is auto-generated" >> "$ENVIRONMENT_ROOT_DIR/conf/env_default"
        echo "# If you want to add/modify variables (or overwrite ones here), edit the 'env_custom' file"  >> "$ENVIRONMENT_ROOT_DIR/conf/env_default"
        echo " " >> "$ENVIRONMENT_ROOT_DIR/conf/env_default"
    fi

}

generateDefaultEnvRcFile () {

    # first argument passed to function
    deleteFlag=$1

    # if argument '-reset' is passed, delete applications file
    if [ "$deleteFlag" == "-reset" ]
    then
        if [ -f "$ENVIRONMENT_ROOT_DIR/conf/.env_rc" ]
        then
            rm -f "$ENVIRONMENT_ROOT_DIR/conf/.env_rc"
        fi
    fi

    # if '.env_rc' doesn't exist, create it
    if [ ! -f "$ENVIRONMENT_ROOT_DIR/conf/.env_rc" ]
    then
        touch "$ENVIRONMENT_ROOT_DIR/conf/.env_rc"
        echo "# This file is auto-generated" >> "$ENVIRONMENT_ROOT_DIR/conf/.env_rc"
        echo "# If you want to add/modify variables 'env_custom' file"  >> "$ENVIRONMENT_ROOT_DIR/conf/.env_rc"
    fi

}

generateDefaultConfFolderStructure () {

    # first argument passed to function
    deleteFlag=$1

    # if argument '-reset' is passed, delete bin directory
    if [ "$deleteFlag" == "-reset" ]
    then
        if [ -d "$ENVIRONMENT_ROOT_DIR/conf" ]
        then
            rm -rf "$ENVIRONMENT_ROOT_DIR/conf"
        fi
    fi

    # if '/conf' doesn't exist, create it
    if [ ! -d "$ENVIRONMENT_ROOT_DIR/conf" ]
    then
        mkdir "$ENVIRONMENT_ROOT_DIR/conf"
    fi

}

generateDefaultBinFolderStructure () {

    # first argument passed to function
    deleteFlag=$1

    # if argument '-reset' is passed, delete bin directory
    if [ "$deleteFlag" == "-reset" ]
    then
        if [ -d "$ENVIRONMENT_ROOT_DIR/bin" ]
        then
            rm -rf "${ENVIRONMENT_ROOT_DIR:?}/bin"
        fi
    fi

    # if '/bin' doesn't exist, create it
    if [ ! -d "$ENVIRONMENT_ROOT_DIR/bin" ]
    then
        mkdir "$ENVIRONMENT_ROOT_DIR/bin"
    fi

    # if '/bin/.linux' doesn't exist, create it
    if [ ! -d "$ENVIRONMENT_ROOT_DIR/bin/.linux" ]
    then
        mkdir "$ENVIRONMENT_ROOT_DIR/bin/.linux"
    fi

}

deployStandardToolCurl () {

    if [ ! -f "$ENVIRONMENT_ROOT_DIR/bin/.linux/curl" ]
    then
        cp "$ENVIRONMENT_ROOT_DIR/lib/binary_installers/linux/curl/curl" "$ENVIRONMENT_ROOT_DIR/bin/.linux/curl"
        chmod 755 "$ENVIRONMENT_ROOT_DIR/bin/.linux/curl"
    fi

    if [ ! -L "$ENVIRONMENT_ROOT_DIR"/bin/curl ]
    then
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/curl "$ENVIRONMENT_ROOT_DIR"/bin/curl
    fi

    # set curl ca cert path

    certPath="/etc/ssl/certs/ca-certificates.crt"
    if [ ! -f "$certPath" ]
    then
        certPath="/etc/pki/tls/certs/ca-bundle.crt"
    fi 

    testPresence=`cat "$ENVIRONMENT_ROOT_DIR"/conf/env_default | grep -c -m 1 CURL_CA_BUNDLE`
    if [ "$testPresence" == "0" ]
    then
        echo "CURL_CA_BUNDLE=$certPath" >> "$ENVIRONMENT_ROOT_DIR"/conf/env_default
    fi

}

deployStandardToolUnzip () {

    if [ ! -f "$ENVIRONMENT_ROOT_DIR/bin/.linux/unzip" ]
    then
        cp "$ENVIRONMENT_ROOT_DIR/lib/binary_installers/linux/unzip/unzip" "$ENVIRONMENT_ROOT_DIR/bin/.linux/unzip"
        chmod 755 "$ENVIRONMENT_ROOT_DIR/bin/.linux/unzip"
    fi

     if [ ! -L "$ENVIRONMENT_ROOT_DIR"/bin/unzip ]
    then
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/unzip "$ENVIRONMENT_ROOT_DIR"/bin/unzip
    fi

}

deployStandardToolTar () {

    if [ ! -d "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tar" ]
    then
        "$ENVIRONMENT_ROOT_DIR/bin/unzip" $ENVIRONMENT_ROOT_DIR/lib/binary_installers/linux/tar/tar.zip -d $ENVIRONMENT_ROOT_DIR/bin/.linux/.tar
        chmod 755 -R "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tar"
    fi

     if [ ! -L "$ENVIRONMENT_ROOT_DIR"/bin/tar ]
    then
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tar/tar "$ENVIRONMENT_ROOT_DIR"/bin/tar
    fi

}

resetEnvSetup () {

    generateDefaultBinFolderStructure -reset
    generateDefaultConfFolderStructure -reset
    generateDefaultEnvCustomFile -reset
    generateDefaultEnvAppFile -reset
    generateDefaultEnvFile -reset
    generateDefaultEnvRcFile -reset
    deployStandardToolCurl
    deployStandardToolUnzip
    deployStandardToolTar
}

shouldBeDeployed () {

    # first argument is name of app to check for deployment
    selectedApp=$1

    if [ "$selectedApp" == "" ]
    then
        echo "please enter an app name"
        exit
    fi

    generateDefaultEnvAppFile

    allAppsContents=$(cat "$ENVIRONMENT_ROOT_DIR/conf/applications")
    allWantedApps=$(echo "$allAppsContents" | grep -v '#' | sed -e 's/ //g')
    ourAppPresent=$(echo "$allWantedApps" | grep -c -m 1 "$selectedApp")

    if [ "$ourAppPresent" == "1" ]
    then
        echo "yes"
    else
        echo "no"
    fi

}

setupDefaultEnvironmentVariables () {

    # package module environment variables
    packageModules=$(ls "$ENVIRONMENT_ROOT_DIR"/lib/package_modules/linux/)
    packageVariables=""

    # path is special, because it compounds
    pathVariable="$ENVIRONMENT_ROOT_DIR/bin:$PATH"

    for i in $packageModules
    do

        packageVar=$("$ENVIRONMENT_ROOT_DIR"/lib/package_modules/linux/"$i" -environmentSetup)
        packageVariables="$packageVariables :: $packageVar"

    done

    IFS=' :: ' read -r -a array <<< "$packageVariables"

    for element in "${array[@]}"
    do

        
        testIfPath=`echo $element | grep -c -m 1 ^PATH `
        if [[ "$testIfPath" == "1" ]]
        then
            echo "*** $element"
            newPathEntry=${element//PATH=/}

            if [[ "$pathVariable" != *"$newPathEntry"* ]]
            then
                pathVariable="$pathVariable:$newPathEntry"
            fi
        else

            testPresence=`cat "$ENVIRONMENT_ROOT_DIR"/conf/env_default | grep -c -m 1 "$element"`
            if [ "$testPresence" == "0" ]
            then
                echo "$element" >> "$ENVIRONMENT_ROOT_DIR"/conf/env_default
            fi
        fi

    done

    testPresence=`cat "$ENVIRONMENT_ROOT_DIR"/conf/env_default | grep -c -m 1 "^PATH="`
    if [ "$testPresence" == "0" ]
    then
        echo "PATH=$pathVariable" >> "$ENVIRONMENT_ROOT_DIR"/conf/env_default
    fi

    testPsEntryCheck=`cat "$ENVIRONMENT_ROOT_DIR"/conf/env_default | grep -c -m 1 "PS1="`
    if [ "$testPsEntryCheck" == 0 ]
    then
        buildEnvironmentTtyPs1
    fi
    

}

writeCustomEnvironmentVariable () {

    # $1 variable name
    # $2 variable value

    # check if variable exists already
    if [ ! -f "$ENVIRONMENT_ROOT_DIR/conf/env_custom" ]
    then
        generateDefaultEnvCustomFile
    fi

    variableExists=`cat "$ENVIRONMENT_ROOT_DIR/conf/env_custom" | grep -v "#" | grep -c -m 1 "$1="`

    if [ "$variableExists" == "1" ]
    then
        sed -i "/$1=/d" "$ENVIRONMENT_ROOT_DIR/conf/env_custom"
    fi

    echo "export $1=$2" >> "$ENVIRONMENT_ROOT_DIR/conf/env_custom"

}

buildEnvRcFileFromConfFiles () {

    cat "$ENVIRONMENT_ROOT_DIR"/conf/env_default | grep -v ^"#" >> conf/.env_rc
    cat "$ENVIRONMENT_ROOT_DIR"/conf/env_custom | grep -v ^"#" >> conf/.env_rc
    
}

buildTempRcRunFile () {

    # first argument passed to function
    exeCmd=$1

    if [ -f /tmp/.env_temp ]
    then
        rm -rf /tmp/.env_temp
    fi

    echo ". $ENVIRONMENT_ROOT_DIR/conf/.env_rc" >> /tmp/.env_temp

    if [ "$1" != "" ]
    then
        echo "$exeCmd" >> /tmp/.env_temp
    fi
    echo "rm -rf /tmp/.env_temp" >> /tmp/.env_temp
    chmod 755 /tmp/.env_temp

}

buildEnvironmentTtyPs1 () {

    # first argument: name of env
    ENVNAME=$1
    ENVPATH="env_custom"

    if [ "$ENVNAME" == "" ]
    then
        ENVNAME="built_environment"
        ENVPATH="env_default"
    fi

    GREEN="\e[32;1m"
    RED="\e[31;1m"
    BLUE="\e[34;1m"
    ENDCOLOR="\e[0m"
    SUCCESS="[${GREEN}*${ENDCOLOR}]"
    FAIL="[${RED}*${ENDCOLOR}]"

    line='PS1='\"${BLUE}[${ENDCOLOR}${GREEN}${ENVNAME}${ENDCOLOR}\ \\W${BLUE}]${ENDCOLOR}${GREEN}\$${ENDCOLOR}\ \"''

    checkExistence=`cat "$ENVIRONMENT_ROOT_DIR"/conf/$ENVPATH | grep -c -m 1 "$ENVNAME"`

    if [ "$checkExistence" != "1" ]
    then
        echo "$line" >> "$ENVIRONMENT_ROOT_DIR"/conf/$ENVPATH
    fi
}
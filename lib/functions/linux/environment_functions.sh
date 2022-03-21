#!/bin/bash
ENVIRONMENT_ROOT_DIR=`echo ${BASH_SOURCE[0]} | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}'`
cd $ENVIRONMENT_ROOT_DIR
cd ..
cd ..
cd ..
ENVIRONMENT_ROOT_DIR=`pwd`




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
        echo "# Add required applications here, one per line" >> "$ENVIRONMENT_ROOT_DIR/conf/applications"
        echo "# Available applications:"  >> "$ENVIRONMENT_ROOT_DIR/conf/applications"
        echo "#     * nodejs"  >> "$ENVIRONMENT_ROOT_DIR/conf/applications"
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

    # if 'applications' doesn't exist, create it
    if [ ! -f "$ENVIRONMENT_ROOT_DIR/conf/env_default" ]
    then
        touch "$ENVIRONMENT_ROOT_DIR/conf/env_default"
        echo "# This file is auto-generated" >> "$ENVIRONMENT_ROOT_DIR/conf/env_default"
        echo "# If you want to add/modify variables (or overwrite ones here), edit the 'env_custom' file"  >> "$ENVIRONMENT_ROOT_DIR/conf/env_default"
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
            rm -rf "$ENVIRONMENT_ROOT_DIR/bin"
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

    if [ ! -L $ENVIRONMENT_ROOT_DIR/bin/curl ]
    then
        ln -s $ENVIRONMENT_ROOT_DIR/bin/.linux/curl $ENVIRONMENT_ROOT_DIR/bin/curl
    fi

}

deployStandardToolUnzip () {

    if [ ! -f "$ENVIRONMENT_ROOT_DIR/bin/.linux/unzip" ]
    then
        cp "$ENVIRONMENT_ROOT_DIR/lib/binary_installers/linux/unzip/unzip" "$ENVIRONMENT_ROOT_DIR/bin/.linux/unzip"
        chmod 755 "$ENVIRONMENT_ROOT_DIR/bin/.linux/unzip"
    fi

     if [ ! -L $ENVIRONMENT_ROOT_DIR/bin/unzip ]
    then
        ln -s $ENVIRONMENT_ROOT_DIR/bin/.linux/unzip $ENVIRONMENT_ROOT_DIR/bin/unzip
    fi

}

resetEnvSetup () {

    generateDefaultBinFolderStructure -reset
    generateDefaultConfFolderStructure -reset
    generateDefaultEnvCustomFile -reset
    generateDefaultEnvAppFile -reset
    generateDefaultEnvFile -reset
    deployStandardToolCurl
    deployStandardToolUnzip
    
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

    allWantedApps=`cat "$ENVIRONMENT_ROOT_DIR/conf/applications" | grep -v '#' | sed -e 's/ //g'`
    ourAppPresent=`echo $allWantedApps | grep -c -m 1 "$selectedApp"`

    if [ "$ourAppPresent" == "1" ]
    then
        echo "yes"
    else
        echo "no"
    fi

}

setupDefaultEnvironmentVariables () {

    # package module environment variables
    packageModules=`ls $ENVIRONMENT_ROOT_DIR/lib/package_modules/linux/`
    packageVariables=""

    # path is special, because it compounds
    pathVariable=`echo "$ENVIRONMENT_ROOT_DIR/bin:$PATH"`

    for i in $packageModules
    do

        packageVar=`$ENVIRONMENT_ROOT_DIR/lib/package_modules/linux/$i -environmentSetup`
        packageVariables="$packageVariables :: $packageVar"

    done

    IFS=' :: ' read -r -a array <<< "$packageVariables"

    for element in "${array[@]}"
    do

        if [[ "$element" == *"PATH"* ]]
        then

            newPathEntry=`echo "$element" | sed -e 's/PATH=//g'`

            if [[ "$pathVariable" != *"$newPathEntry"* ]]
            then
                pathVariable="$pathVariable:$newPathEntry"
            fi
        else
            echo $element >> $ENVIRONMENT_ROOT_DIR/conf/env_default
        fi

    done

    echo "PATH=$pathVariable" >> $ENVIRONMENT_ROOT_DIR/conf/env_default
    buildEnvironmentTtyPs1 >> $ENVIRONMENT_ROOT_DIR/conf/env_default

}

applyDefaultEnvironmentVariables () {

    defaultEnvironmentVars=`cat conf/env_default | grep -v "#" | grep -v -e '^ ' | grep -v -e '^$'`

    for envVar in $defaultEnvironmentVars
    do

        varName=`echo $envVar | awk -F "=" '{print $1}'`
        varValue=`echo $envVar | awk -F "=" '{print $2}'`

        if [ "$varName" == "PS1" ]
        then
            export $varName="$varValue "
        else
            export $varName=$varValue
        fi
        

    done

    defaultCustomVars=`cat conf/env_custom | grep -v "#" | grep -v -e '^ ' | grep -v -e '^$'`

    for envVar in $defaultCustomVars
    do
    
        varName=`echo $envVar | awk -F "=" '{print $1}'`
        varValue=`echo $envVar | awk -F "=" '{print $2}'`

        export $varName=$varValue

    done

}

buildEnvironmentTtyPs1 () {

    projectFolderName=`echo $ENVIRONMENT_ROOT_DIR | awk -F "/" '{print $(NF-1)}'`

    echo "PS1=[[$projectFolderName]]\\$"

}
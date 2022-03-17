#!/bin/bash
ENVIRONMENT_ROOT_DIR=`echo ${BASH_SOURCE[0]} | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}'`
cd $ENVIRONMENT_ROOT_DIR
ENVIRONMENT_ROOT_DIR=`pwd`
. $ENVIRONMENT_ROOT_DIR/lib/functions/linux/environment_functions.sh




generateDefaultConfFolderStructure
generateDefaultEnvCustomFile
generateDefaultEnvAppFile
generateDefaultEnvFile -reset
generateDefaultEnvFile

generateDefaultBinFolderStructure
deployStandardToolUnzip
deployStandardToolCurl



packageModules=`ls $ENVIRONMENT_ROOT_DIR/lib/package_modules/linux/`

for i in $packageModules
do
    chmod 755 $ENVIRONMENT_ROOT_DIR/lib/package_modules/linux/$i
    $ENVIRONMENT_ROOT_DIR/lib/package_modules/linux/$i
done

setupDefaultEnvironmentVariables
applyDefaultEnvironmentVariables


while :; do
    case $1 in

        "-resetEnvironment")
            resetEnvSetup
            exit
            ;;

        *)
            clear
            echo "***"
            echo "NEW CONSOLE SESSION LAUNCHED"
            echo "***"
            exec "/bin/bash"
            exit
            ;;

    esac
done





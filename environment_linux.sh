#!/bin/bash
ENVIRONMENT_ROOT_DIR=$(echo "${BASH_SOURCE[0]}" | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}')
cd "$ENVIRONMENT_ROOT_DIR" || exit
ENVIRONMENT_ROOT_DIR=$(pwd)
source "$ENVIRONMENT_ROOT_DIR"/lib/functions/linux/environment_functions.sh











generateDefaultConfFolderStructure
generateDefaultEnvCustomFile
generateDefaultEnvAppFile
generateDefaultEnvFile -reset
generateDefaultEnvFile

generateDefaultBinFolderStructure
deployStandardToolUnzip
deployStandardToolCurl

setupDefaultEnvironmentVariables
applyDefaultEnvironmentVariables

packageModules=$(ls "$ENVIRONMENT_ROOT_DIR"/lib/package_modules/linux/)

for i in $packageModules
do
    chmod 755 "$ENVIRONMENT_ROOT_DIR"/lib/package_modules/linux/"$i"
    "$ENVIRONMENT_ROOT_DIR"/lib/package_modules/linux/"$i"
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
            cd ..
            clear
            echo " "
            echo "**************************************************"
            echo "** New terminal session with environment set up **"
            echo "** When done be sure to 'exit' this terminal    **"
            echo "**************************************************"
            echo " "
            exec "/bin/bash"
            exit
            ;;

    esac
done





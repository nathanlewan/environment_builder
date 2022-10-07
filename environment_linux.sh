#!/bin/bash
ENVIRONMENT_ROOT_DIR=$(echo "${BASH_SOURCE[0]}" | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}')
cd "$ENVIRONMENT_ROOT_DIR" || exit
ENVIRONMENT_ROOT_DIR=$(pwd)
source "$ENVIRONMENT_ROOT_DIR"/lib/functions/linux/environment_functions.sh
NUMBER_OF_FOLDERS_TO_TRAVERSE=$1


case $1 in

    "-resetEnvironment")
        resetEnvSetup
        exit
        ;;

esac








generateDefaultConfFolderStructure
generateDefaultEnvCustomFile
generateDefaultEnvAppFile
generateDefaultEnvFile -reset
generateDefaultEnvFile
generateDefaultEnvRcFile -reset
generateDefaultEnvRcFile

generateDefaultBinFolderStructure
deployStandardToolUnzip
deployStandardToolCurl
deployStandardToolTar
deployStandardToolUnison
deployStandardToolInotify

setupDefaultEnvironmentVariables
buildEnvRcFileFromConfFiles

packageModules=$(ls "$ENVIRONMENT_ROOT_DIR"/lib/package_modules/linux/)

for i in $packageModules
do
    chmod 755 "$ENVIRONMENT_ROOT_DIR"/lib/package_modules/linux/"$i"
    "$ENVIRONMENT_ROOT_DIR"/lib/package_modules/linux/"$i"
done

setupDefaultEnvironmentVariables
buildEnvRcFileFromConfFiles


while :; do
    case $1 in
    
        "-initializeServer")
            case $3 in

                1) cd ../ ;;
                2) cd ../../ ;;
                3) cd ../../../ ;;
                4) cd ../../../../ ;;
                5) cd ../../../../../ ;;

            esac

            buildTempRcRunFile "$2"

            exec /tmp/.env_temp
            exit
            ;;
        "-help")
            echo "ENVIRONMENT LINUX SETUP"
            echo "  FLAGS:"
            echo "    <none>:                           launch console with environment loaded"
            echo "    <1-5>:                            launch console with # of folders back"
            echo "    -resetEnvironment:                reset everything back to default"
            echo "    -initializeServer '<cmd>':        loads environment, then runs the given <cmd>"
            echo "    -initializeServer '<cmd>' <1-5>:  loads environment from # of folders back, then runs the given <cmd>"
            echo "    -help:                            this help menu"
            exit
            ;;
        *)
            case $NUMBER_OF_FOLDERS_TO_TRAVERSE in

                1) cd ../ ;;
                2) cd ../../ ;;
                3) cd ../../../ ;;
                4) cd ../../../../ ;;
                5) cd ../../../../../ ;;

            esac
            
            if [ -f /tmp/.env_temp ]
            then
                rm -rf /tmp/.env_temp
            fi

            buildTempRcRunFile

            bash --rcfile /tmp/.env_temp
            exit
            ;;

    esac
done





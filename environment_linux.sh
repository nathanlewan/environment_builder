#!/bin/bash
ENVIRONMENT_ROOT_DIR=$(echo "${BASH_SOURCE[0]}" | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}')
cd "$ENVIRONMENT_ROOT_DIR" || exit
ENVIRONMENT_ROOT_DIR=$(pwd)
source "$ENVIRONMENT_ROOT_DIR"/lib/functions/linux/environment_functions.sh
NUMBER_OF_FOLDERS_TO_TRAVERSE=$1










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
        "-initializeServer")
            eval " $2"
            exit
        ;;
        *)
            INCLUDE_WARNING_ABOUT_SPACES="no"
            case $NUMBER_OF_FOLDERS_TO_TRAVERSE in

                1) cd ../ ;;
                2) cd ../../ ;;
                3) cd ../../../ ;;
                4) cd ../../../../ ;;
                5) cd ../../../../../ ;;
                *)
                    INCLUDE_WARNING_ABOUT_SPACES="yes"
                ;;

            esac
            clear
            echo " "
            echo "**********************************************************"
            echo "** New terminal session with environment set up         **"
            echo "** When done be sure to 'exit' this terminal            **"
            if [ $INCLUDE_WARNING_ABOUT_SPACES == "yes" ]
            then
            echo "**                                                      **"
            echo "** If you want to change which folder you end up in,    **"
            echo "** add the number of folders to backtrack as the first  **"
            echo "** argument to the environment_linux.sh script          **"
            fi
            echo "**********************************************************"
            echo " "
            exec "/bin/bash"
            exit
            ;;

    esac
done





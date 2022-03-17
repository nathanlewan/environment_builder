#!/bin/bash
SCRIPT_ROOT_DIR=`echo ${BASH_SOURCE[0]} | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}'`

echo "[create_shrc]:                                  script location: [$SCRIPT_ROOT_DIR]"

cd $SCRIPT_ROOT_DIR
cd ..
cd ..
cd ..

ENV_ROOT_DIR=`pwd`

echo "[create_shrc]:                                  setting root directory to [$ENV_ROOT_DIR]"







# if .sh_api_env exists, delete it so we can re-create
if [ -f $ENV_ROOT_DIR/.sh_api_env ]; then 
    echo "[create_shrc]:                                  removing [$ENV_ROOT_DIR/.sh_api_env] so we can regenerate it"
    rm -rf $ENV_ROOT_DIR/.sh_api_env
fi


# get a list of all environment variables in the different config files
scriptA=`cat $ENV_ROOT_DIR/lib/setup/linux/init_environment.sh | grep export | grep -v "grep export" | grep -v "#" | grep -v -e '^$'`
scriptB=`cat $ENV_ROOT_DIR/lib/conf/linux/environment_variables | grep export | grep -v "grep export" | grep -v "#" | grep -v -e '^$'`
scriptC=`cat $ENV_ROOT_DIR/lib/conf/linux/environment_variables_custom_or_override | grep export | grep -v "grep export" | grep -v "#" | grep -v -e '^$'`


exportedKeys=()
exportedValues=()



if [ "$scriptA" != "" ]; then

    for i in $scriptA;
    do

        if [ "$i" != "export" ]; then

            key=`echo $i | awk -F "=" '{print $1}'`
            value=`echo $i | awk -F "=" '{print $2}'`

            echo "[create_shrc]:                                      KEY = [$key]"
            echo "[create_shrc]:                                      VALUE = [$value]"

            exportedKeys+=( "$key" )
            exportedValues+=( "$value" )
        fi

    done

fi

if [ "$scriptB" != "" ]; then

    for i in $scriptB;
    do

        if [ "$i" != "export" ]; then
            key=`echo $i | awk -F "=" '{print $1}'`
            value=`echo $i | awk -F "=" '{print $2}'`

            exportedKeys+=( "$key" )
            exportedValues+=( "$value" )
        fi

    done

fi

if [ "$scriptC" != "" ]; then

    for i in $scriptC;
    do

        if [ "$i" != "export" ]; then

            key=`echo $i | awk -F "=" '{print $1}'`
            value=`echo $i | awk -F "=" '{print $2}'`

            iterator=0

            for str in "${exportedKeys[@]}";
            do
                
                if [ "$str" == "$key" ]; then
                    exportedValues[$iterator]=$value
                else
                    foundEntry="no"

                    for check in "${exportedKeys[@]}";
                    do
                        if [ "$check" == "$key" ]; then
                            foundEntry="yes"
                        fi
                    done

                    if [ "$foundEntry" == "no" ]; then
                        exportedKeys+=( "$key" )
                        exportedValues+=( "$value" )
                    fi   
                fi
                ((iterator++))

            done

        fi

    done

fi

echo "### " >> $ENV_ROOT_DIR/.sh_api_env
echo "### DON'T EDIT THIS FILE DIRECTLY!" >> $ENV_ROOT_DIR/.sh_api_env
echo "### add variables (or override defaults) in the [$ENV_ROOT_DIR/lib/conf/linux/environment_variables_custom_or_override] file " >> $ENV_ROOT_DIR/.sh_api_env
echo "###" >> $ENV_ROOT_DIR/.sh_api_env
echo " " >> $ENV_ROOT_DIR/.sh_api_env

echo "export ENV_ROOT_DIR=\"$ENV_ROOT_DIR\"" >> $ENV_ROOT_DIR/.sh_api_env

echo "[create_shrc]:                                  generating new [$ENV_ROOT_DIR/.sh_api_env] file"
for b in "${!exportedKeys[@]}"; do
   line="export ${exportedKeys[$b]}=${exportedValues[$b]}"
   echo $line >> $ENV_ROOT_DIR/.sh_api_env
done


lineToAdd=`echo "[[ -f $ENV_ROOT_DIR/.sh_api_env ]] && . $ENV_ROOT_DIR/.sh_api_env"`

if [ -f ~/.bashrc ]; then

    alreadyPresent=`cat ~/.bashrc | grep -c -m 1 sh_api_env`

    if [ $alreadyPresent == 1 ]; then
        echo "[create_shrc]:                                  ~/.bashrc file already contains link to [$ENV_ROOT_DIR/.sh_api_env]"
    else
        echo "[create_shrc]:                                  ~/.bashrc file updated with link to [$ENV_ROOT_DIR/.sh_api_env]"
        echo $lineToAdd >> ~/.bashrc
    fi

elif [ -f ~/.bash_profile ];then

    alreadyPresent=`cat ~/.bash_profile | grep -c -m 1 sh_api_env`

    if [ $alreadyPresent == 1 ]; then
        echo "[create_shrc]:                                  ~/.bashrc file already contains link to [$ENV_ROOT_DIR/.sh_api_env]"
    else
        echo "[create_shrc]:                                  ~/.bash_profile file updated with link to [$ENV_ROOT_DIR/.sh_api_env]"
        echo $lineToAdd >> ~/.bash_profile
    fi

else
    echo "[create_shrc]:                                  no ~/.bash_profile file, creating and adding link to [$ENV_ROOT_DIR/.sh_api_env]"
    echo $lineToAdd >> ~/.bash_profile
fi


if [ -f ~/.zshrc ]; then
    # add to zshrc
    alreadyPresent=`cat ~/.zshrc | grep -c -m 1 sh_api_env`

    if [ $alreadyPresent == 1 ]; then
        echo "[create_shrc]:                                  ~/.zshrc file already contains link to [$ENV_ROOT_DIR/.sh_api_env]"
    else
        echo "[create_shrc]:                                  ~/.zshrc file updated with link to [$ENV_ROOT_DIR/.sh_api_env]"
        echo $lineToAdd >> ~/.zshrc
    fi

fi

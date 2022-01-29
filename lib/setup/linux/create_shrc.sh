#!/bin/bash
api_SCRIPTROOTDIR=`echo ${BASH_SOURCE[0]} | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}'`

echo "[create_shrc]:                                  script location: [$api_SCRIPTROOTDIR]"

cd $api_SCRIPTROOTDIR
cd ..
cd ..
cd ..

api_ENVROOTDIR=`pwd`

echo "[create_shrc]:                                  setting root directory to [$api_ENVROOTDIR]"







# if .sh_api_env exists, delete it so we can re-create
if [ -f $api_ENVROOTDIR/.sh_api_env ]; then 
    echo "[create_shrc]:                                  removing [$api_ENVROOTDIR/.sh_api_env] so we can regenerate it"
    rm -rf $api_ENVROOTDIR/.sh_api_env
fi


# get a list of all environment variables in the different config files
scriptA=`cat $api_ENVROOTDIR/lib/setup/linux/init_environment.sh | grep export | grep -v "grep export" | grep -v "#" | grep -v -e '^$'`
scriptB=`cat $api_ENVROOTDIR/lib/conf/linux/environment_variables | grep export | grep -v "grep export" | grep -v "#" | grep -v -e '^$'`
scriptC=`cat $api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override | grep export | grep -v "grep export" | grep -v "#" | grep -v -e '^$'`


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

echo "### " >> $api_ENVROOTDIR/.sh_api_env
echo "### DON'T EDIT THIS FILE DIRECTLY!" >> $api_ENVROOTDIR/.sh_api_env
echo "### add variables (or override defaults) in the [$api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override] file " >> $api_ENVROOTDIR/.sh_api_env
echo "###" >> $api_ENVROOTDIR/.sh_api_env
echo " " >> $api_ENVROOTDIR/.sh_api_env

echo "export api_ENVROOTDIR=\"$api_ENVROOTDIR\"" >> $api_ENVROOTDIR/.sh_api_env

echo "[create_shrc]:                                  generating new [$api_ENVROOTDIR/.sh_api_env] file"
for b in "${!exportedKeys[@]}"; do
   line="export ${exportedKeys[$b]}=${exportedValues[$b]}"
   echo $line >> $api_ENVROOTDIR/.sh_api_env
done


lineToAdd=`echo "[[ -f $api_ENVROOTDIR/.sh_api_env ]] && . $api_ENVROOTDIR/.sh_api_env"`

if [ -f ~/.bashrc ]; then

    alreadyPresent=`cat ~/.bashrc | grep -c -m 1 sh_api_env`

    if [ $alreadyPresent == 1 ]; then
        echo "[create_shrc]:                                  ~/.bashrc file already contains link to [$api_ENVROOTDIR/.sh_api_env]"
    else
        echo "[create_shrc]:                                  ~/.bashrc file updated with link to [$api_ENVROOTDIR/.sh_api_env]"
        echo $lineToAdd >> ~/.bashrc
    fi

elif [ -f ~/.bash_profile ];then

    alreadyPresent=`cat ~/.bash_profile | grep -c -m 1 sh_api_env`

    if [ $alreadyPresent == 1 ]; then
        echo "[create_shrc]:                                  ~/.bashrc file already contains link to [$api_ENVROOTDIR/.sh_api_env]"
    else
        echo "[create_shrc]:                                  ~/.bash_profile file updated with link to [$api_ENVROOTDIR/.sh_api_env]"
        echo $lineToAdd >> ~/.bash_profile
    fi

else
    echo "[create_shrc]:                                  no ~/.bash_profile file, creating and adding link to [$api_ENVROOTDIR/.sh_api_env]"
    echo $lineToAdd >> ~/.bash_profile
fi


if [ -f ~/.zshrc ]; then
    # add to zshrc
    alreadyPresent=`cat ~/.zshrc | grep -c -m 1 sh_api_env`

    if [ $alreadyPresent == 1 ]; then
        echo "[create_shrc]:                                  ~/.zshrc file already contains link to [$api_ENVROOTDIR/.sh_api_env]"
    else
        echo "[create_shrc]:                                  ~/.zshrc file updated with link to [$api_ENVROOTDIR/.sh_api_env]"
        echo $lineToAdd >> ~/.zshrc
    fi

fi

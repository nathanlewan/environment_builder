#!/bin/bash
SCRIPT_ROOT_DIR=`echo ${BASH_SOURCE[0]} | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}'`

cd $SCRIPT_ROOT_DIR
cd ..
cd ..
cd ..

ENV_ROOT_DIR=`pwd`

echo "[init_environment]:                             setting root directory to [$ENV_ROOT_DIR]"








if [ ! -f $ENV_ROOT_DIR/lib/conf/linux/environment_variables_custom_or_override ]; then
    echo "[init_environment]:                             copying over environment variable override script"
    echo "[init_environment]:                             location: [$ENV_ROOT_DIR/lib/conf/linux/environment_variables_custom_or_override]"
    cp $ENV_ROOT_DIR/lib/installers/linux/environment_variables_custom_or_override $ENV_ROOT_DIR/lib/conf/linux/environment_variables_custom_or_override
    chmod 755 $ENV_ROOT_DIR/lib/conf/linux/environment_variables_custom_or_override
fi

. $ENV_ROOT_DIR/lib/conf/linux/environment_variables
. $ENV_ROOT_DIR/lib/conf/linux/environment_variables_custom_or_override
. $ENV_ROOT_DIR/lib/setup/linux/create_shrc.sh

echo "[init_environment]:                             init run from install_node? [$initRunFromNode]"

if [ "$initRunFromNode" == "yes" ]; then
    echo "[init_environment]:                             don't re-run install_node"
else
    . $ENV_ROOT_DIR/lib/setup/linux/install_node.sh
fi
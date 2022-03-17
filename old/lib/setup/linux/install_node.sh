#!/bin/bash
SCRIPT_ROOT_DIR=`echo ${BASH_SOURCE[0]} | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}'`

cd $SCRIPT_ROOT_DIR
cd ..
cd ..
cd ..

ENV_ROOT_DIR=`pwd`

echo "[install_node]:                                 setting root directory to [$ENV_ROOT_DIR]"









# check if environment is set up
export initRunFromNode="no"

if [ "$api_NODEPATH" == "" ]; then

    echo "[install_node]:                                 nodejs env variables not set, running init_environment"
    export initRunFromNode="yes"
    $ENV_ROOT_DIR/lib/setup/linux/init_environment.sh

fi

if [ ! -d $ENV_ROOT_DIR/lib/bin ]; then
    echo "[install_node]:                                 creating directory [$ENV_ROOT_DIR/lib/bin]"
    mkdir $ENV_ROOT_DIR/lib/bin
fi

if [ ! -d $ENV_ROOT_DIR/lib/bin/linux ]; then
    echo "[install_node]:                                 creating directory [$ENV_ROOT_DIR/lib/bin/linux]"
    mkdir $ENV_ROOT_DIR/lib/bin/linux
fi

if [ ! -d $ENV_ROOT_DIR/lib/bin/linux/node ]; then
    echo "[install_node]:                                 creating directory [$ENV_ROOT_DIR/lib/bin/linux/node]"
    mkdir $ENV_ROOT_DIR/lib/bin/linux/node
fi

if [ ! -d $ENV_ROOT_DIR/lib/bin/linux/node/$NODE_VERSION ]; then
    echo "[install_node]:                                 extracting nodejs version [$NODE_VERSION]"
    tar -xvf $ENV_ROOT_DIR/lib/installers/linux/$NODE_VERSION.tar.xz
    mv $NODE_VERSION $ENV_ROOT_DIR/lib/bin/linux/node/$NODE_VERSION
else
    echo "[install_node]:                                 nodejs installed and available"
fi
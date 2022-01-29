#!/bin/bash
api_SCRIPTROOTDIR=`echo ${BASH_SOURCE[0]} | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}'`

cd $api_SCRIPTROOTDIR
cd ..
cd ..
cd ..

api_ENVROOTDIR=`pwd`

echo "[install_node]:                                 setting root directory to [$api_ENVROOTDIR]"









# check if environment is set up
export initRunFromNode="no"

if [ "$api_NODEPATH" == "" ]; then

    echo "[install_node]:                                 nodejs env variables not set, running init_environment"
    export initRunFromNode="yes"
    $api_ENVROOTDIR/lib/setup/linux/init_environment.sh

fi

if [ ! -d $api_ENVROOTDIR/lib/bin ]; then
    echo "[install_node]:                                 creating directory [$api_ENVROOTDIR/lib/bin]"
    mkdir $api_ENVROOTDIR/lib/bin
fi

if [ ! -d $api_ENVROOTDIR/lib/bin/linux ]; then
    echo "[install_node]:                                 creating directory [$api_ENVROOTDIR/lib/bin/linux]"
    mkdir $api_ENVROOTDIR/lib/bin/linux
fi

if [ ! -d $api_ENVROOTDIR/lib/bin/linux/node ]; then
    echo "[install_node]:                                 creating directory [$api_ENVROOTDIR/lib/bin/linux/node]"
    mkdir $api_ENVROOTDIR/lib/bin/linux/node
fi

if [ ! -d $api_ENVROOTDIR/lib/bin/linux/node/$api_NODEVERSION ]; then
    echo "[install_node]:                                 extracting nodejs version [$api_NODEVERSION]"
    tar -xvf $api_ENVROOTDIR/lib/installers/linux/$api_NODEVERSION.tar.xz
    mv $api_NODEVERSION $api_ENVROOTDIR/lib/bin/linux/node/$api_NODEVERSION
else
    echo "[install_node]:                                 nodejs installed and available"
fi
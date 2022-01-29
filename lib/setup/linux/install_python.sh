#!/bin/bash
api_SCRIPTROOTDIR=`echo ${BASH_SOURCE[0]} | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}'`

cd $api_SCRIPTROOTDIR
cd ..
cd ..
cd ..

api_ENVROOTDIR=`pwd`

echo "[install_python]:                               setting root directory to [$api_ENVROOTDIR]"









# check if environment is set up
export initRunFromPython="no"

if [ "$api_PYTHONPATH" == "" ]; then

    echo "[install_python]:                               python env variables not set, running init_environment"
    export initRunFromPython="yes"
    $api_ENVROOTDIR/lib/setup/linux/init_environment.sh

fi

if [ ! -d $api_ENVROOTDIR/lib/bin ]; then
    echo "[install_python]:                               creating directory [$api_ENVROOTDIR/lib/bin]"
    mkdir $api_ENVROOTDIR/lib/bin
fi

if [ ! -d $api_ENVROOTDIR/lib/bin/linux ]; then
    echo "[install_python]:                               creating directory [$api_ENVROOTDIR/lib/bin/linux]"
    mkdir $api_ENVROOTDIR/lib/bin/linux
fi

if [ ! -d $api_ENVROOTDIR/lib/bin/linux/python ]; then
    echo "[install_python]:                               creating directory [$api_ENVROOTDIR/lib/bin/linux/python]"
    mkdir $api_ENVROOTDIR/lib/bin/linux/python
fi

if [ ! -d $api_ENVROOTDIR/lib/bin/linux/python/$api_PYTHONVERSION ]; then
    echo "[install_python]:                               extracting python version [$api_PYTHONVERSION]"
    tar -xvf $api_ENVROOTDIR/lib/installers/linux/$api_PYTHONVERSION.tar.zst
    mv python $api_ENVROOTDIR/lib/bin/linux/python/$api_PYTHONVERSION
else
    echo "[install_python]:                               python installed and available"
fi
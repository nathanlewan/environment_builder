#!/bin/bash
api_SCRIPTROOTDIR=`echo ${BASH_SOURCE[0]} | sed -e 's|/init_environment.sh||g'`
export api_SCRIPTROOTDIR=$api_SCRIPTROOTDIR

cd $api_SCRIPTROOTDIR
cd ..
cd ..
cd ..

api_ENVROOTDIR=`pwd`
export api_ENVROOTDIR=`pwd`

echo "[init_environment]:                             setting root directory to $api_ENVROOTDIR"


if [ ! -f $api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override ]; then
    echo "[init_environment]:                             copying over override script"
    cp $api_ENVROOTDIR/lib/installers/linux/environment_variables_custom_or_override $api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override
    chmod 755 $api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override
fi

. $api_ENVROOTDIR/lib/conf/linux/environment_variables
. $api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override

if [ -f $api_ENVROOTDIR/.bash_env ]; then 
    rm -rf $api_ENVROOTDIR/.bash_env
fi

echo
#!/bin/bash
api_SCRIPTROOTDIR=`echo ${BASH_SOURCE[0]} | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}'`

cd $api_SCRIPTROOTDIR
cd ..
cd ..
cd ..

api_ENVROOTDIR=`pwd`

echo "[init_environment]:                             setting root directory to [$api_ENVROOTDIR]"








if [ ! -f $api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override ]; then
    echo "[init_environment]:                             copying over environment variable override script"
    echo "[init_environment]:                             location: [$api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override]"
    cp $api_ENVROOTDIR/lib/installers/linux/environment_variables_custom_or_override $api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override
    chmod 755 $api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override
fi

. $api_ENVROOTDIR/lib/conf/linux/environment_variables
. $api_ENVROOTDIR/lib/conf/linux/environment_variables_custom_or_override
. $api_ENVROOTDIR/lib/setup/linux/create_shrc.sh
#!/bin/sh
####################################################################################
# Description: This script mounts a bucket from a cloud based datastore and uses it
# as a shared config directory to pass configuration settings around between machines
# This should only be used if you are deploying from a temporal backup. Baselined
# and virgin deployments shouldn't use this and should have their assets on the 
# local filesystem
# Author: Peter Winter
# Date :  9/4/2016
###################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
####################################################################################
####################################################################################
set -x

cleanup()
{   
        if ( [ -f ${HOME}/runtime/SETTING_UP_ASSETS ] )
        then
                /bin/rm ${HOME}/runtime/SETTING_UP_ASSETS
        fi

        exit
}

trap cleanup 0 1 2 3 6 9 14 15


if ( [ -f ${HOME}/runtime/DATASTORE_CACHE_PURGED ] )
then
        if ( [ -d ${HOME}/s3mount_cache ] && [ "`/usr/bin/find ${HOME}/runtime/DATASTORE_CACHE_PURGED -mtime +5`" != "" ] )
        then
                /usr/bin/find ${HOME}/s3mount_cache -mindepth 1 -mtime +5 -delete
                /bin/touch ${HOME}/runtime/DATASTORE_CACHE_PURGED
        fi
fi


if ( [ -f ${HOME}/runtime/SETTING_UP_ASSETS ] )
then
        exit
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh PERSISTASSETSTOCLOUD:0`" = "1" ] )
then
   exit
fi


directories_to_mount="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:config//g'`"
directories=""
for directory in ${directories_to_mount}
do
        processed_directories="${processed_directories}`/bin/echo "${directory} " | /bin/sed 's/\./\//g'`"
done

applicationassetdirs="${processed_directories}"
applicationassetbuckets="`/bin/echo ${applicationassetdirs} | /bin/sed 's/\//\-/g'`"

/bin/touch ${HOME}/runtime/SETTING_UP_ASSETS

s3fs_gid="`/usr/bin/id -g www-data`"
s3fs_uid="`/usr/bin/id -u www-data`"


if ( [ ! -d ${HOME}/s3mount_cache ] )
then
        /bin/mkdir ${HOME}/s3mount_cache
        /bin/touch ${HOME}/runtime/DATASTORE_CACHE_PURGED
fi

WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

for assetbucket in ${applicationassetbuckets}
do
        assetbuckets="${assetbuckets} `/bin/echo "${WEBSITE_URL}"-assets | /bin/sed 's/\./-/g'`-${assetbucket}"
done

export AWS_ACCESS_KEY_ID="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'S3ACCESSKEY'`"
export AWS_SECRET_ACCESS_KEY="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'S3SECRETKEY'`"
endpoint="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'S3HOSTBASE' | /usr/bin/awk -F':' '{print $1}'`"

loop="1"
for assetbucket in ${assetbuckets}
do
        asset_directory="`/bin/echo ${applicationassetdirs} | /usr/bin/cut -d " " -f ${loop}`"

        if ( [ "`/bin/mount | /bin/grep "/var/www/html/${asset_directory}"`" = "" ] )
        then
                ${HOME}/providerscripts/datastore/MountDatastore.sh ${assetbucket}

                /bin/rm -r ${HOME}/tmp/hold.$$

                if ( [ -d /var/www/html/${asset_directory} ] )
                then
                        /bin/mkdir -p ${HOME}/tmp/hold.$$
                        cd /var/www/html/${asset_directory}
                        /bin/cp -r --parents . ${HOME}/tmp/hold.$$
                fi
                 
                /bin/mkdir -p /var/www/html/${asset_directory}
                /bin/chmod 777 /var/www/html/${asset_directory}
                /bin/chown www-data:www-data /var/www/html/${asset_directory}
                   
                if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:repo'`" = "1" ] )
                then
                        /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o use_cache=${HOME}/s3mount_cache,allow_other,nonempty,kernel_cache,use_path_request_style,max_stat_cache_size=10000,stat_cache_expire=20,multireq_max=3 -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
                elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:binary'`" = "1" ] )
                then
                        /bin/mkdir ~/.aws
                        /bin/chmod 755 ~/.aws
                        /bin/echo "[default]" > ~/.aws/credentials
                        /bin/echo "aws_access_key_id = ${AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials
                        /bin/echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials

                        /usr/bin/goofys -o allow_other --endpoint="https://${endpoint}" --uid="${s3fs_uid}" --gid="${s3fs_gid}" --file-mode=0750 ${assetbucket} /var/www/html/${asset_directory}   
                elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:binary'`" = "1" ] )
                then
                        /bin/mkdir ~/.aws
                        /bin/chmod 755 ~/.aws
                        /bin/echo "[default]" > ~/.aws/credentials
                        /bin/echo "aws_access_key_id = ${AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials
                        /bin/echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials

                        /usr/sbin/geesefs -o allow_other --endpoint="https://${endpoint}" --uid="${s3fs_uid}" --gid="${s3fs_gid}" --file-mode=0750 ${assetbucket} /var/www/html/${asset_directory}    
                elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:rclone'`" = "1" ] )
                then
                        /usr/bin/rclone mount --allow-other --dir-cache-time 2000h --poll-interval 10s --vfs-cache-max-age 90h --vfs-cache-mode full --vfs-cache-max-size 20G  --vfs-cache-poll-interval 5m --cache-dir ${HOME}/s3mount_cache s3:${assetbucket} /var/www/html/${asset_directory} &
                        count="0"

                        while ( [ "`/bin/mount | /bin/grep /var/www/html/${asset_directory}`" = "" ] && [ "${count}" -lt "5" ] )
                        do
                                /bin/sleep 5
                                count="`/usr/bin/expr ${count} + 1`"
                        done
                fi

                if ( [ -d ${HOME}/tmp/hold.$$ ] )
                then
                        cd ${HOME}/tmp/hold.$$
                        /bin/cp -r --parents . /var/www/html/${asset_directory}
                        /bin/rm -r ${HOME}/tmp/hold.$$
                fi
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
done

/bin/rm ${HOME}/runtime/SETTING_UP_ASSETS

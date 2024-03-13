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
#set -x

cleanup()
{   
    if ( [ -f ${HOME}/runtime/SETTING_UP_ASSETS ] )
    then
        /bin/rm ${HOME}/runtime/SETTING_UP_ASSETS
    fi
    
    exit
}

trap cleanup 0 1 2 3 6 9 14 15

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLEDSUCCESSFULLY"`" = "0" ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/SETTING_UP_ASSETS ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh AUTOSCALED:1`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SNAPPED:0`" != "1" ] )
    then
        if ( [ ! -f ${HOME}/runtime/AUTOSCALED_WEBSERVER_ONLINE ] )
        then
            exit
        fi
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PERSISTASSETSTOCLOUD:0`" = "1" ] )
then
   exit
fi

directories_to_mount="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:config//g'`"
directories=""
for directory in ${directories_to_mount}
do
    #processed_directories="${processed_directories}`/bin/echo "${directory} " | /bin/sed 's/.*DIRECTORIESTOMOUNT://g' | /bin/sed 's/:/ /g' | /bin/sed 's/\./\//g'`"
    processed_directories="${processed_directories}`/bin/echo "${directory} " | /bin/sed 's/\./\//g'`"
done

applicationassetdirs="${processed_directories}"
applicationassetbuckets="`/bin/echo ${applicationassetdirs} | /bin/sed 's/\//\-/g'`"

/bin/touch ${HOME}/runtime/SETTING_UP_ASSETS

s3fs_gid="`/usr/bin/id -g www-data`"
s3fs_uid="`/usr/bin/id -u www-data`"

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"

for assetbucket in ${applicationassetbuckets}
do
    assetbuckets="${assetbuckets} `/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-${assetbucket}"
done

export AWSACCESSKEYID=`/bin/grep 'access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
endpoint="`/bin/grep host_base ~/.s3cfg | /usr/bin/awk '{print $NF}'`"

loop="1"
for assetbucket in ${assetbuckets}
do
    asset_directory="`/bin/echo ${applicationassetdirs} | /usr/bin/cut -d " " -f ${loop}`"
    
    if ( [ "`/bin/mount | /bin/grep "/var/www/html/${asset_directory}"`" = "" ] )
    then
        ${HOME}/providerscripts/datastore/MountDatastore.sh "${DATASTORE_CHOICE}" ${assetbucket}

        #Notice I use an S3FS mount to copy the assets to S3 this is because S3FS has difficulty reading from S3 if the objects in S3
        #have been written there using another tool that it itself, for example, s3cmd
            
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
           
        if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'S3FS:repo'`" = "1" ] ||  [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'S3FS:source'`" = "1" ] )
        then
            /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style,max_stat_cache_size=10000,stat_cache_expire=20,multireq_max=3 -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
        elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'GOOF:binaries'`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'GOOF:source'`" = "1" ] )
        then
            /bin/mkdir ~/.aws
            /bin/chmod 755 ~/.aws
            /bin/echo "[default]" > ~/.aws/credentials
            /bin/echo "aws_access_key_id = ${AWSACCESSKEYID}" >> ~/.aws/credentials
            /bin/echo "aws_secret_access_key = ${AWSSECRETACCESSKEY}" >> ~/.aws/credentials

            /usr/bin/goofys -o allow_other --endpoint="https://${endpoint}" --uid="${s3fs_uid}" --gid="${s3fs_gid}" --file-mode=0750 ${assetbucket} /var/www/html/${asset_directory}    
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


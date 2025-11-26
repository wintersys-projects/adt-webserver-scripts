#!/bin/sh
####################################################################################
# Description: This script mounts a bucket from a cloud based datastore and uses it
# as a shared directory.
# This should only be used if you are deploying from a temporal backup. Baselined
# and virgin deployments shouldn't use this and should have their assets on the 
# local filesystem.
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

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" = "1" ] && [ ! -f ${HOME}/runtime/INITIAL_WEBROOT_SYNC_DONE ] )
then
	exit
fi

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

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:0`" = "1" ] )
then
	exit
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] )
then
	exit
fi

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
application_asset_dirs="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:/ /g'`"

application_asset_buckets=""
for directory in ${application_asset_dirs}
do
        asset_bucket="`/bin/echo "${WEBSITE_URL}-assets-${directory}" | /bin/sed -e 's/\./-/g' -e 's;/;-;g' -e 's/--/-/g'`"
        application_asset_buckets="${application_asset_buckets} ${asset_bucket}"
done

/bin/touch ${HOME}/runtime/SETTING_UP_ASSETS

s3fs_gid="`/usr/bin/id -g www-data`"
s3fs_uid="`/usr/bin/id -u www-data`"

if ( [ ! -d ${HOME}/s3mount_cache ] )
then
	/bin/mkdir ${HOME}/s3mount_cache
	/bin/touch ${HOME}/runtime/DATASTORE_CACHE_PURGED
fi


export AWS_ACCESS_KEY_ID="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3ACCESSKEY'`"
export AWS_SECRET_ACCESS_KEY="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3SECRETKEY'`"
endpoint="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3HOSTBASE' | /usr/bin/awk -F':' '{print $1}'`"


loop="1"
for asset_bucket in ${application_asset_buckets}
do
	asset_directory="`/bin/echo ${application_asset_dirs} | /usr/bin/cut -d " " -f ${loop}`"
	assets_backup_directory="${HOME}/runtime/application_assets_backup/${WEBSITE_URL}/${asset_directory}"

	if ( [ "`/bin/echo ${asset_directory} | /bin/grep "^/"`" = "" ] )
	then
		asset_directory="/var/www/html/${asset_directory}"
	fi 

	if ( [ ! -f ${assets_backup_directory} ] )
	then
		if ( [ ! -d ${assets_backup_directory} ] )
		then
			/bin/mkdir -p ${assets_backup_directory}
        fi

		if ( [ -d ${asset_directory} ] )
		then
        	/bin/mv ${asset_directory}/* ${assets_backup_directory}
		else
			/bin/mkdir -p ${asset_directory}
		fi
	fi
		
	if ( [ "`/bin/mount | /bin/grep "${asset_directory}"`" = "" ] )
	then
		${HOME}/providerscripts/datastore/MountDatastore.sh ${asset_bucket}
		if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:repo'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:source'`" = "1" ] )
		then
			/usr/bin/s3fs -o use_cache=${HOME}/s3mount_cache,allow_other,kernel_cache,use_path_request_style,uid=${s3fs_uid},gid=${s3fs_gid},max_stat_cache_size=10000,stat_cache_expire=20,multireq_max=3 -ourl=https://${endpoint} ${asset_bucket} ${asset_directory} &
		elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:binary'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:source'`" = "1" ] )
		then
			/bin/mkdir ~/.aws
			/bin/chmod 755 ~/.aws
			/bin/echo "[default]" > ~/.aws/credentials
			/bin/echo "aws_access_key_id = ${AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials
			/bin/echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials

			/usr/bin/goofys -o allow_other --endpoint="https://${endpoint}" --uid="${s3fs_uid}" --gid="${s3fs_gid}" --file-mode=0644 --dir-mode=0755  ${asset_bucket} ${asset_directory}   
		elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:binary'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:source'`" = "1" ] )
		then
			/bin/mkdir ~/.aws
			/bin/chmod 755 ~/.aws
			/bin/echo "[default]" > ~/.aws/credentials
			/bin/echo "aws_access_key_id = ${AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials
			/bin/echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials

			/usr/bin/geesefs -o allow_other --endpoint="https://${endpoint}" --list-type=1 --uid=${s3fs_uid} --gid=${s3fs_gid} --setuid=${s3fs_uid} --setgid=${s3fs_gid}  --file-mode=0644 --dir-mode=0755 --cache=${HOME}/s3mount_cache --cache-file-mode=0644 ${asset_bucket} ${asset_directory}    
		elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:rclone:repo'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:rclone:binary'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:rclone:source'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:rclone:script'`" = "1" ] )
		then
			/usr/bin/rclone mount --config /root/.config/rclone/rclone.conf-1 --allow-other --dir-cache-time 2000h --poll-interval 10s --vfs-cache-max-age 90h --vfs-cache-mode full --vfs-cache-max-size 20G  --vfs-cache-poll-interval 5m --cache-dir ${HOME}/s3mount_cache s3:${asset_bucket} ${asset_directory} &
			count="0"

			while ( [ "`/bin/mount | /bin/grep ${asset_directory}`" = "" ] && [ "${count}" -lt "5" ] )
			do
				/bin/sleep 5
				count="`/usr/bin/expr ${count} + 1`"
			done
		fi
	fi
	loop="`/usr/bin/expr ${loop} + 1`"

	if ( [ "`/bin/mount | /bin/grep "${asset_directory}"`" != "" ] && [ -d ${asset_directory} ] && [ -d ${assets_backup_directory} ] )
	then
			/bin/cp -r ${assets_backup_directory}/* ${asset_directory}
    fi
done

/bin/rm ${HOME}/runtime/SETTING_UP_ASSETS

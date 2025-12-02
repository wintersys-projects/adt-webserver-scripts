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

#if the s3 cache size grows to be greater than 10G, clean it out
s3_cache_size="`/usr/bin/du -h --max-depth=1 /home | /bin/grep s3mount_cache | /usr/bin/awk '{print $1}' | /bin/grep 'G$' | /bin/sed 's/G//g'`" 

if ( [ "${s3_cache_size}" != "" ] && [ "${s3_cache_size}" -gt "10" ] )
then
        /bin/rm -r /home/s3mount_cache/*
fi

if ( [ ! -d /home/s3mount_cache ] )
then
        /bin/mkdir /home/s3mount_cache
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

/bin/touch ${HOME}/runtime/SETTING_UP_ASSETS

merged="0"
if ( [ "`/bin/echo ${application_asset_dirs} | /bin/grep 'merge='`" != "" ] )
then
        merged="1"
        if ( [ ! -f /usr/bin/mergerfs ] )
        then
                BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
                ${HOME}/installscripts/InstallMergerFS.sh ${BUILDOS}
        fi
		if ( [ ! -f ${HOME}/runtime/mergerfs.config ] )
		then
			/bin/cp ${HOME}/providerscripts/datastore/assets/config/mergerfs.conf ${HOME}/runtime/mergerfs.config
		fi
fi

not_for_merge_mount_dirs=""
mount_dirs_for_merge=""

for setting in ${application_asset_dirs}
do
        if ( [ "`/bin/echo ${setting} | /bin/grep '^merge='`" != "" ] )
        then
                no_dirs="`/bin/echo ${setting} | sed -E 's/.*(.)/\1/'`"
                bucket_dir="`/bin/echo ${setting} | /bin/sed 's/.$//g' | /bin/sed 's/merge=//g'`"
                count="1"
                while ( [ "${count}" -le "${no_dirs}" ] )
                do
                        mount_dirs_for_merge="${mount_dirs_for_merge}${bucket_dir}${count}:"
                        count="`/usr/bin/expr ${count} + 1`"
                done
                mount_dirs_for_merge="${mount_dirs_for_merge} "
        else
                not_for_merge_mount_dirs="${not_for_merge_mount_dirs}${setting}:"
        fi
done

mount_dirs_for_merge="`/bin/echo ${mount_dirs_for_merge} | /bin/sed 's/:$/ /g'`"
not_for_merge_mount_dirs="`/bin/echo ${not_for_merge_mount_dirs} | /bin/sed 's/:$//g'`"
mount_dirs_for_merge_set=""
for merge_dir in ${mount_dirs_for_merge}
do
        bucket_dir="`/bin/echo ${merge_dir} | /bin/sed 's/:/ /g' | /usr/bin/awk '{print $1}' | /bin/sed 's/[0-9]$//g'`" 
        mount_dirs_for_merge_set="${mount_dirs_for_merge_set}${bucket_dir} ${merge_dir}|"
done

mount_dirs_for_merge_set="`/bin/echo ${mount_dirs_for_merge_set} | /bin/sed 's/|$//g'`"
dirs_to_mount_to="`/bin/echo ${mount_dirs_for_merge_set} | /usr/bin/awk -F '|' '{for (i = 1; i <= NF; i++){print $i}}' | /usr/bin/awk '{print $NF}'`"
dirs_to_merge_to="`/bin/echo ${mount_dirs_for_merge_set} | /usr/bin/awk -F '|' '{for (i = 1; i <= NF; i++){print $i}}' | /usr/bin/awk '{print $1}'`"
dirs_to_mount_to="`/bin/echo ${not_for_merge_mount_dirs}:${dirs_to_mount_to} | /bin/sed 's/:/ /g'`"
application_asset_dirs="${dirs_to_mount_to}"

application_asset_buckets=""
for directory in ${application_asset_dirs}
do
        asset_bucket="`/bin/echo "${WEBSITE_URL}-assets-${directory}" | /bin/sed -e 's/\./-/g' -e 's;/;-;g' -e 's/--/-/g'`"
        application_asset_buckets="${application_asset_buckets} ${asset_bucket}"
done

backup_dirs="${not_for_merge_mount_dirs} ${dirs_to_merge_to}"

for backup_dir in ${backup_dirs}
do
        if ( [ "${backup_dir}" = "webroot" ] )
        then
                backup_dir=""
        else
                backup_dir="/${backup_dir}"
        fi

        assets_backup_directory="${HOME}/runtime/application_assets_backup/${WEBSITE_URL}${backup_dir}"

        if ( [ ! -d ${assets_backup_directory} ] )
        then
                /bin/mkdir -p ${assets_backup_directory}
        fi

        if ( [ -d /var/www//html${backup_dir} ] )
        then
                if ( [ "`/bin/mount | /bin/grep -P "/var/www/html${backup_dir}(?=\s|$)"`" = "" ] )
                then
                        /bin/mv /var/www/html${backup_dir}/* ${assets_backup_directory}
                        /bin/rm -r /var/www/html${backup_dir}/*
                fi
        else
                /bin/mkdir  -p /var/www//html${backup_dir}
        fi
done    

s3fs_gid="`/usr/bin/id -g www-data`"
s3fs_uid="`/usr/bin/id -u www-data`"

export AWS_ACCESS_KEY_ID="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3ACCESSKEY' | /usr/bin/awk -F'|' '{print $1}'`"
export AWS_SECRET_ACCESS_KEY="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3SECRETKEY' | /usr/bin/awk -F'|' '{print  $1}'`"
endpoint="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3HOSTBASE' | /usr/bin/awk -F'|' '{print  $1}'`"

loop="1"
for asset_bucket in ${application_asset_buckets}
do
        asset_directory="`/bin/echo ${application_asset_dirs} | /usr/bin/cut -d " " -f ${loop}`"

        if ( [ "${not_for_merge_mount_dirs}" != "" ] && [ "`/bin/echo ${not_for_merge_mount_dirs} | /bin/grep "${asset_directory}"`" != "" ] )
        then
                asset_directory="/var/www/html/${asset_directory}"
        else
                asset_directory="/var/www/${asset_directory}"
        fi

        if ( [ ! -d ${asset_directory} ] )
        then
                /bin/mkdir -p ${asset_directory}
        fi

        if ( [ "`/bin/mount  | /bin/grep -P "${asset_directory}(?=\s|$)"`" = "" ] )
        then
                ${HOME}/providerscripts/datastore/MountDatastore.sh ${asset_bucket}
				
                if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:repo'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:source'`" = "1" ] )
                then
						/bin/cp ${HOME}/providerscripts/datastore/assets/config/s3fs.conf ${HOME}/runtime/s3fs.conf
						/bin/sed -i -e "s/XXXXS3UIDXXXX/${s3fs_uid}/g" -e "s/XXXXS3GIDXXXX/${s3fs_gid}/g" -e "s;XXXXENDPOINTXXXX;${endpoint};g" ${HOME}/runtime/s3fs.conf
						password_file="`/bin/grep "passwd_file" ${HOME}/runtime/s3fs.conf | /usr/bin/awk -F'=' '{print $NF}'`"
                        /bin/echo "${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}" > ${password_file}
                        /bin/chmod 600 ${password_file}
						
						options="-o "
						for option in `/bin/cat ${HOME}/runtime/s3fs.conf`
						do
							options="${options}${option},"
						done
						options="`/bin/echo ${options} | /bin/sed 's/,$//g'`"

						/usr/bin/s3fs ${options} ${asset_bucket} ${asset_directory} &

			    elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:binary'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:source'`" = "1" ] )
                then
				        if ( [ ! -d /root/.aws ] )
                        then
                                /bin/mkdir /root/.aws
                        fi
						
                        /bin/chmod 755 /root/.aws
                        /bin/echo "[default]" > /root/.aws/credentials
                        /bin/echo "aws_access_key_id = ${AWS_ACCESS_KEY_ID}" >> /root/.aws/credentials
                        /bin/echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> /root/.aws/credentials
						/bin/chmod 600 /root/.aws/credentials
						
						/bin/cp ${HOME}/providerscripts/datastore/assets/config/goofys.conf ${HOME}/runtime/goofys.conf

						/bin/sed -i -e "s/XXXXS3UIDXXXX/${s3fs_uid}/g" -e "s/XXXXS3GIDXXXX/${s3fs_gid}/g" -e "s;XXXXENDPOINTXXXX;${endpoint};g" ${HOME}/runtime/goofys.conf
 
						options=" "
						for option in `/bin/cat ${HOME}/runtime/goofys.conf`
						do
							options="${options}${option} "
						done
						
						/usr/bin/goofys ${options} ${asset_bucket} ${asset_directory}  &

                elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:binary'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:source'`" = "1" ] )
                then
                        if ( [ ! -d /root/.aws ] )
                        then
                                /bin/mkdir /root/.aws
                        fi
                        /bin/chmod 755 /root/.aws
                        /bin/echo "[default]" > /root/.aws/credentials
                        /bin/echo "aws_access_key_id = ${AWS_ACCESS_KEY_ID}" >> /root/.aws/credentials
                        /bin/echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> /root/.aws/credentials

						/bin/cp ${HOME}/providerscripts/datastore/assets/config/geesefs.conf ${HOME}/runtime/geesefs.conf
                        /bin/sed -i -e "s/XXXXS3UIDXXXX/${s3fs_uid}/g" -e "s/XXXXS3GIDXXXX/${s3fs_gid}/g" -e "s;XXXXENDPOINTXXXX;${endpoint};g" ${HOME}/runtime/geesefs.conf

                        options=" "
                        for option in `/bin/cat ${HOME}/runtime/geesefs.conf`
                        do
                                options="${options}${option} "
                        done

						/usr/bin/geesefs ${options} ${asset_bucket} ${asset_directory} &
						
                elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:rclone:repo'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:rclone:binary'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:rclone:source'`" = "1" ] || [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:rclone:script'`" = "1" ] )
                then
						/bin/cp ${HOME}/providerscripts/datastore/assets/config/rclone.conf ${HOME}/runtime/rclone.conf
                        /bin/sed -i -e "s/XXXXS3UIDXXXX/${s3fs_uid}/g" -e "s/XXXXS3GIDXXXX/${s3fs_gid}/g" -e "s;XXXXENDPOINTXXXX;${endpoint};g" ${HOME}/runtime/rclone.conf

                        options=" "
                        for option in `/bin/cat ${HOME}/runtime/rclone.conf`
                        do
                                options="${options}${option} "
                        done
						
                        /usr/bin/rclone mount ${options} s3:${asset_bucket} ${asset_directory} &
                        count="0"
                fi

                while ( [ "`/bin/mount  | /bin/grep -P "${asset_directory}(?=\s|$)"`" = "" ] && [ "${count}" -lt "10" ] )
                do
                        /bin/sleep 5
                        count="`/usr/bin/expr ${count} + 1`"
                done

                if ( [ "${count}" = "10" ] )
                then
                        ${HOME}/providerscripts/email/SendEmail.sh "DIRECTORY ${asset_directory} NOT MOUNTED" "A mount has failed for directory ${asset_directory}" "ERROR"
                else
					#This will walk the mounted directory and prime us up
					/bin/grep -r "GhdJjbgudbuJD" ${asset_directory} &
				fi
        fi

        loop="`/usr/bin/expr ${loop} + 1`"
done

if ( [ "${merged}" = "1" ] )
then
	for dir_to_merge_to in  ${dirs_to_merge_to}
	do
		if ( [ "`/bin/mount | /bin/grep -P "/var/www/html/${dir_to_merge_to}(?=\s|$)" | /bin/grep 'mergerfs'`" = "" ] )
		then
			for dir_to_merge in ${dirs_to_mount_to}
			do
				dirs_to_merge="${dirs_to_merge} `/bin/echo "${dir_to_merge}" | /bin/grep -ow "${dir_to_merge_to}[0-9]$"`"
			done
			dirs_to_merge="`/bin/echo ${dirs_to_merge} | /usr/bin/tr '\n' ' '`"

			full_path_dirs_to_merge=""
			for dir in ${dirs_to_merge}
			do
				full_path_dirs_to_merge="${full_path_dirs_to_merge}/var/www/${dir}:"
			done

			full_path_dirs_to_merge="`/bin/echo ${full_path_dirs_to_merge} | /bin/sed 's/:$//g'`"

			if ( [ "${dir_to_merge_to}" = "webroot" ] )
			then
				dir_to_merge_to=""
				full_path_dir_to_merge_to="/var/www/html"
			else
				full_path_dir_to_merge_to="/var/www/html/${dir_to_merge_to}"
			fi

			if ( [ ! -d ${full_path_dir_to_merge_to} ] )
			then
				/bin/mkdir -p ${full_path_dir_to_merge_to}
			fi

			if ( [ "`/bin/mount | /bin/grep -P "${full_path_dir_to_merge_to}(?=\s|$)" | /bin/grep 'mergerfs'`" = "" ] )
			then
				/usr/bin/mergerfs ${full_path_dirs_to_merge} ${full_path_dir_to_merge_to} -o config=${HOME}/runtime/mergerfs.config -o allow_other
				/bin/sleep 5
			fi

			dirs_to_merge=""
			if ( [ "`/bin/mount | /bin/grep -P "${full_path_dir_to_merge_to}(?=\s|$)" | /bin/grep 'mergerfs'`" != "" ] )
			then
				if ( [ ! -f ${HOME}/runtime/ASSETS_COPIED_TO_MERGED_WEBROOT ] )
				then
					if ( [ ! -f /var/www/html/XXXXXX-DO_NOT_REMOVE ] )
					then
						/bin/cp -rn ${HOME}/runtime/application_assets_backup/${WEBSITE_URL}/${dir_to_merge_to}/* ${full_path_dir_to_merge_to}
						if ( [ "$?" = "0" ] )
						then
							/bin/touch ${HOME}/runtime/ASSETS_COPIED_TO_MERGED_WEBROOT
						fi
					fi
				fi
			fi
		fi
	done
fi

/bin/rm ${HOME}/runtime/SETTING_UP_ASSETS

#!/bin/sh
######################################################################################################
# Description: This script will synchronise the webroots when "SYNC_WEBROOTS" is set to 1 
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

config_file="`${HOME}/application/configuration/GetApplicationConfigFilename.sh`"
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"
MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

command_body=""
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
        do
                command_body="${command_body} --exclude '/"${dir}"' --include '/"${dir}"/'"
        done
fi

command_body="${command_body} --exclude '"${config_file}"'" 

if ( [ ! -d ${HOME}/runtime/webroot_sync/outgoing ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/outgoing
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/processed ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/processed
fi

if ( [ ! -d /var/www/html1 ] )
then
        /usr/bin/rsync -av ${command_body} /var/www/html/ /var/www/html1
else
        echo "added"
        for file in `/usr/bin/rsync -rv --checksum --ignore-times ${command_body} /var/www/html/ /var/www/html1 | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /bin/sed '/^$/d'`
        do
                /usr/bin/tar frp ${HOME}/runtime/webroot_sync/outgoing/additions.${machine_ip}.$$.tar.gz  /var/www/html/${file} --owner=www-data --group=www-data
                /usr/bin/rsync -a /var/www/html/${file} /var/www/html1/${file}
                /bin/chown www-data:www-data /var/www/html1/${file}
                /bin/chmod 644 /var/www/html1/${file}
        done
        echo "removed"
        for file in `/usr/bin/rsync -rv --checksum --ignore-times ${command_body} /var/www/html1/ /var/www/html | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /bin/sed '/^$/d'`
        do
                /usr/bin/tar frp ${HOME}/runtime/webroot_sync/outgoing/deletes.${machine_ip}.$$.tar.gz  /var/www/html1/${file} --owner=www-data --group=www-data
                /bin/rm /var/www/html1/${file}
        done
fi

if ( [ "${MULTI_REGION}" != "1" ] )
then
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/additions.${machine_ip}.$$.tar.gz ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/additions.${machine_ip}.$$.tar.gz webrootsync/additions "yes"
        fi
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletes.${machine_ip}.$$.tar.gz ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletes.${machine_ip}.$$.tar.gz webrootsync/deletions "yes"
        fi
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh webrootsync/additions ${HOME}/runtime/webroot_sync/incoming
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh webrootsync/deletions ${HOME}/runtime/webroot_sync/incoming
else
        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"

        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/additions.${machine_ip}.$$.tar.gz ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/additions.${machine_ip}.$$.tar.gz ${multi_region_bucket}/webrootsync/additions "yes"
        fi

        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletes.${machine_ip}.$$.tar.gz ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletions.${machine_ip}.$$.tar.gz ${multi_region_bucket}/webrootsync/deletions "yes"
        fi
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh ${multi_region_bucket}/webrootsync/additions ${HOME}/runtime/webroot_sync/incoming
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh ${multi_region_bucket}/webrootsync/deletions ${HOME}/runtime/webroot_sync/incoming
fi

for archive in `/bin/ls -l ${HOME}/runtime/webroot_sync/incoming | /bin/grep additions | /usr/bin/awk '{print $NF}'`
do
        if ( [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
        then
                /bin/tar xvf ${HOME}/runtime/webroot_sync/incoming/${archive} -C / --keep-newer-files
                for file in `/bin/tar tvf ${HOME}/runtime/webroot_sync/incoming/${archive} | /usr/bin/awk '{print $NF}'`
                do
                        file="/${file}"
                        destination_file="`/bin/echo ${file} | /bin/sed 's;/html/;/html1/;'`"
                        /bin/cp "${file}" "${destination_file}"
                        /bin/chown www-data:www-data ${destination_file}
                        /bin/chmod 644 ${destination_file}
                done
                /bin/touch ${HOME}/runtime/webroot_sync/processed/${archive}
        fi
done

for archive in `/bin/ls -l ${HOME}/runtime/webroot_sync/incoming | /bin/grep deletes | /usr/bin/awk '{print $NF}'`
do
        if ( [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
        then
                deletes="`/bin/tar tvf ${HOME}/runtime/webroot_sync/incoming/${archive} -C / --keep-newer-files | /usr/bin/awk '{print $NF}'`"
                for file in ${deletes}
                do
                        file="/${file}"
                        sync_file="`/bin/echo ${file} | /bin/sed 's;/html1/;/html/;'`"
                        if ( [ -f ${file} ] )
                        then
                                /bin/rm ${file}
                        fi
                        if ( [ -f ${sync_file} ] )
                        then
                                /bin/rm ${sync_file}
                        fi
                done
        fi
done

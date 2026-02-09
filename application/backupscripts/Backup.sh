#!/bin/sh
###################################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This is the backup script for the webroot. It can be run hourly, daily, weekly,
# monthly or bimonthly.
# Please make sure these repositories are kept private as if you have deployed a website which has 
# sensitive information as part of its sourcecode, then, there are people who trawl public repositories 
# and look for sensitive information like access keys and so on with the idea of using them for unauthorised 
# activity
###################################################################################################
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

if ( [ "$1" = "" ] )
then
        /bin/echo "This script needs to be run with the <build periodicity> parameter"
        exit
fi

if ( [ "`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "INSTALLED_SUCCESSFULLY"`" = "" ] )
then
        exit
fi

if ( [ ! -f ${HOME}/runtime/WEBSERVER_READY ] )
then
        exit
fi

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"

WEBSITE_DISPLAY_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
#DIRSTOOMIT="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"

CLOUDHOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"
MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTI_REGION'`"
PRIMARY_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PRIMARYREGION'`"

period="`/bin/echo $1 | /usr/bin/tr '[:upper:]' '[:lower:]'`"

allowed_periods="hourly daily weekly monthly bimonthly shutdown"

if ( [ "`/bin/echo ${allowed_periods} | /bin/grep ${period}`" = "" ] )
then
        /bin/echo "Invalid periodicity passed to backup script"
        exit
fi

if ( [ -d ${HOME}/backuparea ] )
then
        /bin/rm -r ${HOME}/backuparea
fi

/bin/mkdir ${HOME}/backuparea
cd ${HOME}/backuparea

exclude_list=`${HOME}/application/configuration/GetApplicationConfigFilename.sh`
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        exclude_list="${exclude_list} `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`"
fi

exclude_command=""
if ( [ "${exclude_list}" != "" ] )
then
        /bin/echo "${exclude_list}" | /bin/tr ' ' '\n' | /bin/sed -e 's;^/;;' -e 's;^;/;' > ${HOME}/backuparea/exclusion_list.dat
        exclude_command="--exclude-from ${HOME}/backuparea/exclusion_list.dat"
fi

#I sync the webroot to a holding directory to make the backup from excluding any asset directories that  have been mounted 
command="/usr/bin/rsync -av ${exclude_command} /var/www/html/ ${HOME}/backuparea"

#if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
#then
#        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
#        do
#                command="${command} --exclude '/"${dir}"' --include '/"${dir}"/'"
#        done
#fi

#command="${command} /var/www/html/ ${HOME}/backuparea"

${HOME}/application/customise/CustomiseBackupByApplication.sh

eval "${command}"

#Add a marker file that we can test for to ensure the integrity of the backup
/bin/touch ${HOME}/backuparea/XXXXXX-DO_NOT_REMOVE

#Make any customisations that tbe backup needs to have made
${HOME}/application/customise/CustomiseBackupByApplication.sh ${HOME}/backuparea

provider_id=""

if ( [ "${MULTI_REGION}" = "1" ] && [ "${PRIMARY_REGION}" = "0" ] )
then
        provider_id=-"${CLOUDHOST}"
fi

#datastore="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}${provider_id}"

#Mount the datastore that we are going to write the backup to
${HOME}/providerscripts/datastore/operations/MountDatastore.sh "backup" "distributed" "${period}${provider_id}"




if ( [ ! -d ${HOME}/livebackup ] )
then
        /bin/mkdir ${HOME}/livebackup
else
        /bin/rm -r ${HOME}/livebackup/*
fi

/usr/bin/find . -name ".*" -exec tar cvfz ${HOME}/livebackup/applicationsourcecode.tar.gz {} +

#Check that a backup hasn't just been made by another webserver
#backup_file="${datastore}/applicationsourcecode.tar.gz"
backup_file="applicationsourcecode.tar.gz"

if ( [ ! -f ${HOME}/livebackup/applicationsourcecode.tar.gz ] )
then
        /bin/echo "Backup file ${HOME}/livebackup/applicationsourcecode.tar.gz not successfully generated"
        exit
fi

if ( [ "`${HOME}/providerscripts/datastore/operations/ListFromDatastore.sh "backup" "${backup_file}" "${period}${provider_id}"`" != "" ] )
then
        if ( [ "`${HOME}/providerscripts/datastore/operations/AgeOfDatastoreFile.sh "backup" "${backup_file}" "${period}${provider_id}"`" -lt "300" ] )
        then
                exit
        fi
fi
set -x
#Write the backup to the datastore
if ( [ -f ${HOME}/livebackup/applicationsourcecode.tar.gz ] )
then
        if ( [ "`${HOME}/providerscripts/datastore/operations/ListFromDatastore.sh "backup" "${backup_file}.BACKUP" "${period}${provider_id}"`" != "" ] )
        then
                ${HOME}/providerscripts/datastore/operations/DeleteFromDatastore.sh "backup" "${backup_file}.BACKUP" "${period}${provider_id}"
        fi
        if ( [ "`${HOME}/providerscripts/datastore/operations/ListFromDatastore.sh "backup" "${backup_file}" "${period}${provider_id}"`" != "" ] )
        then
                ${HOME}/providerscripts/datastore/operations/MoveDatastore.sh "backup" "${backup_file}" "${backup_file}.BACKUP" "distributed" "${period}${provider_id}"
        fi

        /bin/systemd-inhibit --why="Persisting sourcecode to datastore" ${HOME}/providerscripts/datastore/operations/PutToDatastore.sh "backup" "${HOME}/livebackup/applicationsourcecode.tar.gz" "root" "distributed" "no" "${period}${provider_id}"
        /bin/rm -r ${HOME}/livebackup
fi

#Verify that we are happy that the backup is present in the datastore
${HOME}/application/backupscripts/VerifyBackupPresent.sh ${period}
${HOME}/application/customise/UnCustomiseBackupByApplication.sh

cd ${HOME}

if ( [ -d ${HOME}/backuparea ] )
then
        /bin/rm -rf ${HOME}/backuparea
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" = "1" ] )
then
        ${HOME}/providerscripts/datastore/filesystems-sync/heavyweight/DeleteHistoricalAdditions.sh "/var/www/html"
fi

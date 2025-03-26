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
#
if ( [ "$1" = "" ] )
then
	/bin/echo "This script needs to be run with the <build periodicity> parameter"
	exit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLED_SUCCESSFULLY"`" = "0" ] )
then
	exit
fi

if ( [ ! -f ${HOME}/runtime/WEBSERVER_READY ] )
then
	exit
fi

WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
DIRSTOOMIT="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"


DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DATASTORECHOICE'`"
period="`/bin/echo $1 | /usr/bin/tr '[:upper:]' '[:lower:]'`"

allowed_periods="hourly daily weekly monthly bimonthly"

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

#I sync the webroot to a holding directory to make the backup from excluding any asset directories mounted from the S3 datastore
   
command="/usr/bin/rsync -av --exclude='"

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh PERSISTASSETSTOCLOUD:1`" = "1" ] )
then
	for dir in ${DIRSTOOMIT}
	do
		command="${command}/${dir}' --exclude='"
	done
fi

command="`/bin/echo ${command} | /usr/bin/awk '{$NF=""; print $0}'` /var/www/html/* ${HOME}/backuparea"
eval ${command}
#Add a marker file that we can test for to ensure the integrity of the backup
/bin/touch ${HOME}/backuparea/XXXXXX-DO_NOT_REMOVE

#Make any customisations that tbe backup needs to have made
${HOME}/providerscripts/application/customise/CustomiseBackupByApplication.sh

#if ( [ -f /tmp/backup/index.php.backup ] )
#then
#	/bin/cp /tmp/backup/index.php /tmp/backup/index.php.veteran
#	/bin/cp /tmp/backup/index.php.backup /tmp/backup/index.php
#fi

datastore="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}"

#Mount the datastore that we are going to write the backup to
${HOME}/providerscripts/datastore/MountDatastore.sh "${datastore}"

#Bundle up the webroot files that have made it to our holding directory into a tar archive
${HOME}/providerscripts/application/processing/BundleSourcecodeByApplication.sh "${HOME}/backuparea"

if ( [ ! -f ${HOME}/livebackup ] )
then
	/bin/mkdir ${HOME}/livebackup
else
	/bin/rm -r ${HOME}/livebackup/*
fi

/bin/tar cPvfz ${HOME}/livebackup/applicationsourcecode.tar.gz ${HOME}/backuparea

#Check that a backup hasn't just been made by another webserver

backup_file="${datastore}/applicationsourcecode.tar.gz"
if ( [ "`${HOME}/providerscripts/datastore/AgeOfDatastoreFile.sh ${backup_file}`" -lt "300" ] )
then
	exit
fi

#Write the backup to the datastore
if ( [ -f /tmp/applicationsourcecode.tar.gz ] )
then
	${HOME}/providerscripts/datastore/DeleteFromDatastore.sh "${backup_file}.BACKUP"
	${HOME}/providerscripts/datastore/MoveDatastore.sh "${backup_file}" "${backup_file}.BACKUP"
	/bin/systemd-inhibit --why="Persisting sourcecode to datastore" ${HOME}/providerscripts/datastore/PutBackupToDatastore.sh ${HOME}/livebackup/applicationsourcecode.tar.gz "${datastore}"
	/bin/rm  /tmp/applicationsourcecode.tar.gz
fi

#Verify that we are happy that the backup is present in the datastore
${HOME}/providerscripts/backupscripts/VerifyBackupPresent.sh ${period}
${HOME}/providerscripts/application/customise/UnCustomiseBackupByApplication.sh

/bin/rm -rf ${HOME}/backuparea

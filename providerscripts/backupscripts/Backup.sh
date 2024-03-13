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
# Depending on SUPERSAFEWEBROOT backups will be made to your git provider or your datastore or both
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

if ( [ ! -d ${HOME}/logs/backups ] )
then
    /bin/mkdir -p ${HOME}/logs/backups
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLEDSUCCESSFULLY"`" = "0" ] )
then
    exit
fi

if ( [ ! -f ${HOME}/runtime/WEBSERVER_READY ] )
then
    exit
fi

#The log files for the server build are written here...
log_file="backup_out_`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/backups/${log_file}
err_file="backup_err_`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/backups/${err_file}

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"

if ( [ "$1" = "" ] || [ "$2" = "" ] )
then
    /bin/echo "This script needs to be run with the <build periodicity> parameter and the <build identifier> parameter"
    exit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
    exit
fi

/bin/echo "${0} `/bin/date`: Performing the backup of the master webroot" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
#/usr/bin/find /var/www/html -name "sed*" -print -delete

/bin/rm -r /tmp/backup
/bin/mkdir /tmp/backup
cd /tmp/backup
   
DISTOOMIT="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
    
command="/usr/bin/rsync -av --exclude='"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PERSISTASSETSTOCLOUD:1`" = "1" ] )
then
    for dir in ${DISTOOMIT}
    do
        command="${command}/${dir}' --exclude='"
    done
fi

command="`/bin/echo ${command} | /usr/bin/awk '{$NF=""; print $0}'` /var/www/html/* /tmp/backup"
eval ${command}
/bin/touch /tmp/backup/XXXXXX-DO_NOT_REMOVE

/bin/echo "${0} `/bin/date`: Running a backup" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

. ${HOME}/providerscripts/utilities/SetupInfrastructureIPs.sh

${HOME}/providerscripts/application/customise/CustomiseBackupByApplication.sh

APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"

periodicity="$1"

if ( [ "$1" = "HOURLY" ] )
then
    period="hourly"
fi
if ( [ "$1" = "DAILY" ] )
then
    period="daily"
fi
if ( [ "$1" = "WEEKLY" ] )
then
    period="weekly"
fi
if ( [ "$1" = "MONTHLY" ] )
then
    period="monthly"
fi
if ( [ "$1" = "BIMONTHLY" ] )
then
    period="bimonthly"
fi
if ( [ "$1" = "SHUTDOWN" ] )
then
   period="shutdown"
fi
if ( [ "$1" = "MANUAL" ] )
then
   period="manual"
fi

BUILD_IDENTIFIER="$2"

if ( [ "${BUILD_IDENTIFER}" = "" ] )
then
    BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
fi

ip="`${HOME}/providerscripts/utilities/GetIP.sh`"

if ( [ -f /tmp/backup/index.php.backup ] )
then
    /bin/cp /tmp/backup/index.php /tmp/backup/index.php.veteran
    /bin/cp /tmp/backup/index.php.backup /tmp/backup/index.php
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:1`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:2`" = "1" ] )
then
    if ( [ "${period}" = "hourly" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DISABLEHOURLY:1`" = "1" ] )
    then
        /bin/echo "${0} `/bin/date`: Skipping hourly backup to datastore because hourly backups are disabled to save on data transfer costs" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    else
       # ${HOME}/providerscripts/datastore/MountDatastore.sh "${DATASTORE_CHOICE}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}"
        ${HOME}/providerscripts/datastore/MountDatastore.sh "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}"
        ${HOME}/providerscripts/application/processing/BundleSourcecodeByApplication.sh "/tmp/backup"
        ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${DATASTORE_CHOICE} "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}/applicationsourcecode.tar.gz.BACKUP"
        ${HOME}/providerscripts/datastore/MoveDatastore.sh ${DATASTORE_CHOICE} "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}/applicationsourcecode.tar.gz" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}/applicationsourcecode.tar.gz.BACKUP"
        /bin/systemd-inhibit --why="Persisting sourcecode to datastore" ${HOME}/providerscripts/datastore/PutToDatastore.sh "${DATASTORE_CHOICE}" /tmp/applicationsourcecode.tar.gz "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}"
    fi
fi

if ( [ "${period}" = "hourly" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DISABLEHOURLY:1`" = "1" ] )
then
    /bin/echo "${0} `/bin/date`: Skipping hourly backup to repository because hourly backups are disabled to save on data transfer costs" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
elif ( [ "${period}" = "manual" ] )
then
    if ( [ ! -d /tmp/backup_archive ] )
    then
        /bin/mkdir /tmp/backup_archive
    fi
    /bin/rm -r /tmp/backup_archive/*
    /bin/tar cvfz /tmp/backup_archive/backup${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-${period}-${BUILD_IDENTIFIER}.tar.gz /tmp/backup/* 
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:0`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:1`" = "1" ] )
then   
    ${HOME}/providerscripts/git/DeleteRepository.sh "${APPLICATION_REPOSITORY_USERNAME}" "${APPLICATION_REPOSITORY_PASSWORD}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}" "${period}" "${BUILD_IDENTIFIER}" "${APPLICATION_REPOSITORY_PROVIDER}"
    ${HOME}/providerscripts/git/CreateRepository.sh "${APPLICATION_REPOSITORY_USERNAME}" "${APPLICATION_REPOSITORY_PASSWORD}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}" "${period}" "${BUILD_IDENTIFIER}" "${APPLICATION_REPOSITORY_PROVIDER}"
    /bin/sleep 15
    /bin/systemd-inhibit --why="Persisting sourcecode to git repo" ${HOME}/providerscripts/git/GitPushSourcecode.sh "." "Automated Backup" "${APPLICATION_REPOSITORY_PROVIDER}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-${period}-${BUILD_IDENTIFIER}"
    /bin/sleep 15
fi

${HOME}/providerscripts/backupscripts/VerifyBackupPresent.sh ${period}

${HOME}/providerscripts/application/customise/UnCustomiseBackupByApplication.sh
/bin/rm -rf /tmp/backup



#!/bin/sh
###################################################################################
# Author: Peter Winter
# Date :  20/12/2023
# Description: This will verify the presence or absence of a backup
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
######################################################################################
######################################################################################
period="${1}"

APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
APPLICATION_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONIDENTIFIER'`"

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
BUILD_ARCHIVE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"
APPLICATION_REPOSITORY_NAME="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-${period}-${BUILD_IDENTIFIER}"


if ( [ ! -d /root/backupverification ] )
then
    /bin/mkdir /root/backupverification
fi

/bin/rm -r  /root/backupverification/*
/bin/rm -r  /root/backupverification/.git

cd /root/backupverification

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:0`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:1`" = "1" ] ) 
then
    /usr/bin/git init
    ${HOME}/providerscripts/git/GitPull.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} "${APPLICATION_REPOSITORY_NAME}" 1>&2 > /dev/null

    if ( [ "`/bin/ls /root/backupverification/XXXXXX-DO_NOT_REMOVE`" = "" ] )
    then
        /bin/echo "Backup is absent in git repository"
        ${HOME}/providerscripts/email/SendEmail.sh "Potential missing webroot backup for periodicity ${BUILD_ARCHIVE_CHOICE} in your git repository" "A Backup that I expected seems to be missing in the git repository" "INFO"
        /bin/touch ${HOME}/runtime/BACKUP_MISSING
    else
        /bin/echo "Backup is present in git repository"
        ${HOME}/providerscripts/email/SendEmail.sh "Backup has been made to your git repo" "A Backup has been successfully written to your git repository" "INFO"
    fi
else 
    /bin/echo "Not expecting backup to git no backup made"
fi

/bin/rm -r  /root/backupverification/*
/bin/rm -r  /root/backupverification/.git

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:1`" = "1" ] ||  [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:2`" = "1" ] )
then
    application_datastore="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}/applicationsourcecode.tar.gz"
    ${HOME}/providerscripts/datastore/GetFromDatastore.sh "${DATASTORE_CHOICE}" ${application_datastore} 1>&2 > /dev/null
    /bin/tar xvfz /root/backupverification/applicationsourcecode.tar.gz 1>&2 > /dev/null

    if ( [ "`/bin/ls /root/backupverification/tmp/backup/XXXXXX-DO_NOT_REMOVE`" = "" ] )
    then
        /bin/echo "Backup is absent in datastore"
        ${HOME}/providerscripts/email/SendEmail.sh "Potential missing webroot backup for periodicity ${BUILD_ARCHIVE_CHOICE} in your datastore" "A Backup that I expected seems to be missing in the git repository" "INFO"
        /bin/touch ${HOME}/runtime/BACKUP_MISSING
    else
        /bin/echo "Backup is present in datastore"
        ${HOME}/providerscripts/email/SendEmail.sh "Backup has been made to your datastore" "A Backup has been successfully written to your datastore" "INFO"
    fi
else 
    /bin/echo "Not expecting backup to datastore no backup made"
fi
/bin/rm -r /root/backupverification

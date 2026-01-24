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

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
BUILD_ARCHIVE_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"
BUILD_IDENTIFIER="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
APPLICATION_REPOSITORY_NAME="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-${period}-${BUILD_IDENTIFIER}"

if ( [ ! -d ${HOME}/backupverification ] )
then
	/bin/mkdir ${HOME}/backupverification
else 
	/bin/rm -r  ${HOME}/backupverification/*
fi

cd ${HOME}/backupverification

#application_datastore="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}/applicationsourcecode.tar.gz"
#${HOME}/providerscripts/datastore/dedicated/GetFromDatastore.sh ${application_datastore} 

${HOME}/providerscripts/datastore/dedicated/GetFromDatastore.sh "backup" "${period}/applicationsourcecode.tar.gz"
/bin/tar xvfz ${HOME}/backupverification/applicationsourcecode.tar.gz

if ( [ "`/bin/ls ${HOME}/backupverification/XXXXXX-DO_NOT_REMOVE`" = "" ] )
then
	/bin/echo "Backup is absent in datastore"
	${HOME}/providerscripts/email/SendEmail.sh "Potential missing webroot backup for periodicity ${BUILD_ARCHIVE_CHOICE} in your datastore" "A Backup that I expected seems to be missing in the git repository" "ERROR"
else
	/bin/echo "Backup is present in datastore"
	${HOME}/providerscripts/email/SendEmail.sh "Backup has been made to your datastore" "A Backup has been successfully written to your datastore" "INFO"
fi

/bin/rm -r ${HOME}/backupverification

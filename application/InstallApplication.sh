#!/bin/sh
###########################################################################################################
# Description: This script will  install an application sourcecode based on application style, virgin, baseline
# or temporal
# Author: Peter Winter
# Date: 05/02/2017
###########################################################################################################
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

HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
BUILD_ARCHIVE_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_TOKEN="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYTOKEN'`"
APPLICATION_BASELINE_SOURCECODE_REPOSITORY="`${HOME}/utilities/config/ExtractConfigValues.sh 'APPLICATIONBASELINESOURCECODEREPOSITORY' 'stripped' | /bin/sed 's/ /:/g'`"

if ( [ -d /var/www/html ] )
then
        #/bin/rm -r /var/www/html/* 2>/dev/null
        /usr/bin/find /var/www/html -type f -name "*" -delete 2>/dev/null
        /bin/rm -r /var/www/html/.git 2>/dev/null
else
        /bin/mkdir -p /var/www/html
fi

cd /var/www/html
/usr/bin/git init

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] && [ "${APPLICATION}" != "none" ] )
then
        ${HOME}/application/configuration/InstallVirginDeploymentByApplication.sh ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}
        ${HOME}/application/configuration/InstallDirectoryConfigurationByApplication.sh
        ${HOME}/application/configuration/InitialiseVirginInstallByApplication.sh &
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] && [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
then
        ${HOME}/providerscripts/git/GitCloneForWebroot.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_OWNER} ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY} ${APPLICATION_REPOSITORY_TOKEN}
        ${HOME}/application/configuration/InstallDirectoryConfigurationByApplication.sh
        ${HOME}/application/branding/ApplyApplicationBranding.sh
elif ( [ "`/bin/echo 'hourly daily weekly monthly bimonthly' | /bin/grep ${BUILD_ARCHIVE_CHOICE}`" != "" ] )
then
        cd ${HOME}
      #  application_datastore="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${BUILD_ARCHIVE_CHOICE}/applicationsourcecode.tar.gz"
       # ${HOME}/providerscripts/datastore/dedicated/GetFromDatastore.sh ${application_datastore}
        ${HOME}/providerscripts/datastore/operations/GetFromDatastore.sh "backup" "applicationsourcecode.tar.gz" "." "${BUILD_ARCHIVE_CHOICE}"
        if ( [ ! -d ${HOME}/application_sourcecode ] )
        then
                /bin/mkdir ${HOME}/application_sourcecode
        fi
        /bin/tar xvfz ${HOME}/applicationsourcecode.tar.gz -C ${HOME}/application_sourcecode
        /bin/rm ${HOME}/applicationsourcecode.tar.gz
        /bin/rm -r /var/www/html/* 2>/dev/null
        /bin/mv ${HOME}/application_sourcecode/* /var/www/html
        /bin/mv ${HOME}/application_sourcecode/.* /var/www/html
        /bin/rm -rf ${HOME}/application_sourcecode
        ${HOME}/application/configuration/InstallDirectoryConfigurationByApplication.sh
fi

${HOME}/application/customise/CustomiseApplication.sh

if ( [ "`${HOME}/application/configuration/CheckIfApplicationIsInstalled.sh`" = "1" ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "I BELIEVE STRONGLY AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from the datastore: ${BUILD_ARCHIVE_CHOICE} has been installed" "INFO"
        /bin/touch ${HOME}/runtime/BESPOKE_APPLICATION_INSTALLED
else
        ${HOME}/providerscripts/email/SendEmail.sh "I BELIEVE STRONGLY AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from the datastore: ${BUILD_ARCHIVE_CHOICE} has been installed" "INFO"
fi

${HOME}/utilities/security/EnforcePermissions.sh &
/bin/rm -rf /var/www/html/.git

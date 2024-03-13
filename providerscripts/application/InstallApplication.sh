#!/bin/sh
###########################################################################################################
# Description: This script will  install an application sourcecode. First of all it looks in the git repo
# and then in the datastore.
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
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "1" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh credentials/shit ${HOME}/shit
fi

if ( [ -d /var/www/html ] )
then
    /bin/rm -r /var/www/html/* 2>/dev/null
    /bin/rm -r /var/www/html/.* 2>/dev/null
else
    /bin/mkdir -p /var/www/html
fi

cd /var/www/html
/usr/bin/git init

application_to_install="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATION'`"
INSTALLED_VIRGIN_APPLICATION="0"
INSTALLED_VIRGIN_APPLICATION="`${HOME}/providerscripts/application/configuration/InstallVirginDeploymentByApplication.sh ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}`"
if ( [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] && [ "${INSTALLED_VIRGIN_APPLICATION}" = "0" ] )
then
    ${HOME}/providerscripts/git/GitPull.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}
    ${HOME}/providerscripts/email/SendEmail.sh "AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from repository: ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY} has been installed" "INFO"
elif ( [ "${INSTALLED_VIRGIN_APPLICATION}" = "0" ] )
then
    installation_status="0"
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:0`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:1`" = "1" ] )
    then
        application_repository_name="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-${BUILD_ARCHIVE_CHOICE}-${BUILD_IDENTIFIER}"
        ${HOME}/providerscripts/git/GitPull.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${application_repository_name}
       
        if ( [ "`${HOME}/providerscripts/application/configuration/CheckIfApplicationIsInstalled.sh`" = "1" ] )
        then
            if ( [ "`${HOME}/providerscripts/application/configuration/VerifyApplicationType.sh`" = "1" ] )
            then
                /bin/echo "${0} I believe strongly that a ${application_to_install} application has been installed from your git repository ${application_repository_name}" >> ${HOME}/logs/BUILD_PROCESS_MONITORING.log
                ${HOME}/providerscripts/email/SendEmail.sh "I BELIEVE STRONGLY AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from repository: ${application_repository_name} has been installed" "INFO"
                installation_status="1"
            else
                /bin/echo "${0} I am doubtful that a ${application_to_install} application has been installed from your git repository ${application_repository_name}" >> ${HOME}/logs/BUILD_PROCESS_MONITORING.log
                ${HOME}/providerscripts/email/SendEmail.sh "I AM DOUBTFUL THAT AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from repository: ${application_repository_name} has been installed" "ERROR"
            fi
        else
            if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:0`" = "1" ] )
            then
                 /bin/echo "${0} I am doubtful that a ${application_to_install} application has been installed from your git repository ${application_repository_name}" >> ${HOME}/logs/BUILD_PROCESS_MONITORING.log
                 ${HOME}/providerscripts/email/SendEmail.sh "I AM DOUBTFUL THAT AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from repository: ${application_repository_name} has been installed" "ERROR"
            elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:1`" = "1" ] )  
            then
                /bin/echo "${0} I am doubtful that a ${application_to_install} application has been installed from your git repository ${application_repository_name}" >> ${HOME}/logs/BUILD_PROCESS_MONITORING.log
                /bin/echo "${0} I will look in your datastore to see if I can install your sourcecode from there" >> ${HOME}/logs/BUILD_PROCESS_MONITORING.log
                installation_status="0"
            fi
        fi
    fi
    if ( ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:1`" = "1" ] && [ "${installation_status}" = "0" ] ) ||  [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:2`" = "1" ] )
    then
        cd ${HOME}
        application_datastore="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${BUILD_ARCHIVE_CHOICE}/applicationsourcecode.tar.gz"
        ${HOME}/providerscripts/datastore/GetFromDatastore.sh "${DATASTORE_CHOICE}" ${application_datastore}
        /bin/tar xvfz ${HOME}/applicationsourcecode.tar.gz
        /bin/rm ${HOME}/applicationsourcecode.tar.gz
        /bin/mv ${HOME}/tmp/backup/* /var/www/html
        /bin/rm -rf ${HOME}/tmp
        if ( [ "`${HOME}/providerscripts/application/configuration/CheckIfApplicationIsInstalled.sh`" = "1" ] )
        then
            if ( [ "`${HOME}/providerscripts/application/configuration/VerifyApplicationType.sh`" = "1" ] )
            then
                /bin/echo "${0} I believe strongly that a  ${application_to_install} application has been installed from your S3 compatible datastore s3://${application_datastore}" >> ${HOME}/logs/BUILD_PROCESS_MONITORING.log
                ${HOME}/providerscripts/email/SendEmail.sh "I BELIEVE STRONGLY AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from the datastore: ${BUILD_ARCHIVE_CHOICE} has been installed" "INFO"
            else
                /bin/echo "${0} I am doubtful that a  ${application_to_install} application has been installed from your S3 compatible datastore s3://${application_datastore}" >> ${HOME}/logs/BUILD_PROCESS_MONITORING.log
                ${HOME}/providerscripts/email/SendEmail.sh "I AM DOUBTFUL THAT AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from the datastore: ${BUILD_ARCHIVE_CHOICE} has been installed" "ERROR"
            fi
        else
            /bin/echo "${0} I am doubtful that a  ${application_to_install} application has been installed from your S3 compatible datastore s3://${application_datastore}" >> ${HOME}/logs/BUILD_PROCESS_MONITORING.log
            ${HOME}/providerscripts/email/SendEmail.sh "I AM DOUBTFUL THAT AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from the datastore: ${BUILD_ARCHIVE_CHOICE} has been installed" "ERROR"
        fi
    fi
fi


/bin/rm -rf /var/www/html/.git

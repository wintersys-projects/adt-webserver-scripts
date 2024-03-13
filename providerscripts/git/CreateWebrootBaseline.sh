#!/bin/sh
################################################################################################
# Description: You can use this script to manually generate a new baseline for your webroot
# you should run it with the command :
#
#         export HOME=/home/xxxxxx && /home/xxxxxx/providerscipts/git/CreateWebrootBaseline.sh
#
# Author: Peter Winter
# Date :  9/4/2016
#################################################################################################
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

if ( [ "${1}" = "" ] )
then
    /bin/echo "Your application type is set to: `${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONIDENTIFIER'`"
    /bin/echo "Please make very sure this is correct for your application otherwise things will break"
    /bin/echo "Press <enter> when you are sure"
    read x
    
    /bin/echo "Also, please make sure that there is an empty repository of the format <identifier>-webroot-sourcecode-baseline"
    /bin/echo "With your repository provider"
    /bin/echo "Building a baseline and storing it in your repository may take a little while"
    /bin/echo "Please enter an identifier for your baseline for example 'mysocialnetwork'"
    read baseline_name
else
    baseline_name="${1}"
fi

/bin/echo "Creating baseline of your webroot sourcecode in the webserver with the following logs stored on it"

if ( [ ! -d ${HOME}/logs/backups ] )
then
    /bin/mkdir -p ${HOME}/logs/backups
fi

#The log files for the server build are written here...
log_file="baseline_out_`/bin/date | /bin/sed 's/ //g'`"
err_file="baseline_err_`/bin/date | /bin/sed 's/ //g'`"

/bin/echo "Log file is at: ${HOME}/logs/backups/${log_file}"
/bin/echo "Error file is at: ${HOME}/logs/backups/${err_file}"

exec 1>>${HOME}/logs/backups/${log_file}
exec 2>>${HOME}/logs/backups/${err_file}

APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"

WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
WEBSITE_DISPLAY_NAME_FIRST="`/bin/echo ${WEBSITE_DISPLAY_NAME_LOWER} | /bin/sed -e 's/\b\(.\)/\u\1/g'`"

/bin/mkdir -p ${HOME}/backups/${baseline_name}
cd ${HOME}/backups/${baseline_name}

/bin/cp -r /var/www/html/* .

/bin/cp ${HOME}/providerscripts/git/gitattributes .gitattributes
. ${HOME}/providerscripts/application/branding/RemoveApplicationBranding.sh
/bin/rm -r ./.git
/usr/bin/find ${HOME}/backups/${baseline_name} -type d -name .git -exec /bin/rm -rf {} \;
${HOME}/providerscripts/application/customise/CustomiseBackupByApplication.sh ${baseline_name}
/bin/cp ${HOME}/backups/${baseline_name}/index.php.backup ${HOME}/backups/${baseline_name}/index.php
/usr/bin/git init
/usr/bin/git add .gitattributes
/usr/bin/git add .
/usr/bin/git branch -M main

REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER' | /bin/sed 's/_/ /g'`"

if ( [ "${REPOSITORY_PROVIDER}" = "bitbucket" ] )
then
    /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@bitbucket.org/${APPLICATION_REPOSITORY_OWNER}/${baseline_name}-webroot-sourcecode-baseline.git
elif ( [ "${REPOSITORY_PROVIDER}" = "github" ] )
then
    /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@github.com/${APPLICATION_REPOSITORY_OWNER}/${baseline_name}-webroot-sourcecode-baseline.git
elif ( [ "${REPOSITORY_PROVIDER}" = "gitlab" ] )
then
    /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@gitlab.com/${APPLICATION_REPOSITORY_OWNER}/${baseline_name}-webroot-sourcecode-baseline.git
fi

/usr/bin/git add .gitattributes

/usr/bin/git commit -m "Baseline Baby"

/usr/bin/git push -u origin main

/usr/bin/git add .

/usr/bin/git commit -m "Baseline Baby"

/usr/bin/git push -u origin main

${HOME}/providerscripts/application/customise/UnCustomiseBackupByApplication.sh

exec 1>>/dev/tty

/bin/echo "==============DO YOU NEED ASSETS TO BE SETUP?????========================================================================="
/bin/echo "Depending on your deployment plans, you might want the assets of your new baseline to be mounted from your S3 object store"
/bin/echo "If that is the case, you should run ${HOME}/providerscripts/datastore/SetupAssetsStore.sh on this machine"
/bin/echo "NOTE: this will use the setting DIRECTORIES_TO_MOUNT to determine which assets need to be stored in your S3 datastore"
/bin/echo "==============================================================================================================================="

/bin/echo ""
/bin/echo "==================================================================================================================================="
/bin/echo "I consider your baseline to be complete you should verify the repository ${baseline_name}-webroot-sourcecode-baseline with ${REPOSITORY_PROVIDER} for user: ${APPLICATION_REPOSITORY_USERNAME}" 
/bin/echo "==================================================================================================================================="

/bin/rm -r ${HOME}/backups/${baseline_name}/*

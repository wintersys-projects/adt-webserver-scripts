#!/bin/sh
################################################################################################
# Description: You can use this script to manually generate a new baseline for your webroot
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
	/bin/echo "Your application type is set to: `${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
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

if ( [ "${baseline_name}" = "" ] )
then
	/bin/echo "Identifier can't be blank"
	exit
fi


/bin/echo "Creating baseline of your webroot"

if ( [ ! -d ${HOME}/logs/backups ] )
then
	/bin/mkdir -p ${HOME}/logs/backups
fi

/bin/rm -r ${HOME}/backups/* 2>/dev/null

if ( [ -d ${HOME}/.git ] )
then
	/bin/rm -r ${HOME}/.git
fi

if ( [ "${1}" != "" ] )
then
	/bin/echo "the following logs available on your webserver"
	#The log files for the server build are written here...
	log_file="baseline_out_`/bin/date | /bin/sed 's/ //g'`"
	err_file="baseline_err_`/bin/date | /bin/sed 's/ //g'`"

	/bin/echo "Log file is at: ${HOME}/logs/backups/${log_file}"
	/bin/echo "Error file is at: ${HOME}/logs/backups/${err_file}"

	exec 1>>${HOME}/logs/backups/${log_file}
	exec 2>>${HOME}/logs/backups/${err_file}
fi

APPLICATION_REPOSITORY_USERNAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"

WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
WEBSITE_DISPLAY_NAME_FIRST="`/bin/echo ${WEBSITE_DISPLAY_NAME_LOWER} | /bin/sed -e 's/\b\(.\)/\u\1/g'`"

if ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME}  ${APPLICATION_REPOSITORY_OWNER} ${baseline_name}-webroot-sourcecode-baseline ${APPLICATION_REPOSITORY_PASSWORD} 2>&1 | /bin/grep 'Repository not found'`" != "" ] )
then
	if ( [ "${1}" = "" ] )
	then
		/bin/echo "Repository not found, do you want me to create one () (Y|y)"
		read response
		if ( [ "`/bin/echo "Y y" | /bin/grep ${response}`" != "" ] )
		then
			/bin/echo "Creating a new repository"
			${HOME}/providerscripts/git/CreateRepository.sh ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${baseline_name}-webroot-sourcecode-baseline ${APPLICATION_REPOSITORY_PROVIDER}
			if ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME}  ${APPLICATION_REPOSITORY_OWNER} ${baseline_name}-webroot-sourcecode-baseline ${APPLICATION_REPOSITORY_PASSWORD} 2>&1 | /bin/grep 'Repository not found'`" = "" ] )
			then
				/bin/echo "Repository (${baseline_name}-webroot-sourcecode-baseline) successfully created"
				/bin/echo "Press <enter> to continue"
				read x
			else
				/bin/echo "Repository (${baseline_name}-webroot-sourcecode-baseline) not created I will need to exit"
				exit 1
			fi
		fi
	else
		${HOME}/providerscripts/git/CreateRepository.sh ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${baseline_name}-webroot-sourcecode-baseline ${APPLICATION_REPOSITORY_PROVIDER}
		if ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_OWNER} ${baseline_name}-webroot-sourcecode-baseline ${APPLICATION_REPOSITORY_PASSWORD} 2>&1 | /bin/grep 'Repository not found'`" = "" ] )
		then
			/bin/echo "Repository (${baseline_name}-webroot-sourcecode-baseline) successfully created"
		else
			/bin/echo "Repository (${baseline_name}-webroot-sourcecode-baseline) not created I will need to exit"
			exit 1
		fi
	fi
elif ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_OWNER} ${baseline_name}-webroot-sourcecode-baseline ${APPLICATION_REPOSITORY_PASSWORD} 2>&1`" = "" ] )
then
	/bin/echo "Suitable repo (${baseline_name}-webroot-sourcecode-baseline) found, press <enter> to continue"
	read x
elif ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_OWNER} ${baseline_name}-webroot-sourcecode-baseline ${APPLICATION_REPOSITORY_PASSWORD} 2>&1 | /bin/grep 'HEAD'`" != "" ] )
then
	/bin/echo "repository (${baseline_name}-webroot-sourcecode-baseline) found but its not empty. Please either empty the repository or delete it or rename it and allow this script to create a fresh one. Will exit now, please rerun me once this is actioned"
	exit 1
fi

${HOME}/application/customise/CustomiseBackupByApplication.sh

/bin/mkdir -p ${HOME}/backups/${baseline_name}
cd ${HOME}/backups/${baseline_name}

/bin/cp -r /var/www/html/* .
/bin/cp /var/www/html/.* .

${HOME}/application/customise/CustomiseBackupByApplication.sh ${baseline_name}

/bin/cp ${HOME}/providerscripts/git/gitattributes .gitattributes
. ${HOME}/application/branding/RemoveApplicationBranding.sh
/bin/rm -r ./.git
/usr/bin/find ${HOME}/backups/${baseline_name} -type d -name .git -exec /bin/rm -rf {} \;
/bin/cp ${HOME}/backups/${baseline_name}/index.php.backup ${HOME}/backups/${baseline_name}/index.php
/usr/bin/git init

/usr/bin/git branch -M main

REPOSITORY_PROVIDER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER' | /bin/sed 's/_/ /g'`"

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

/usr/bin/git add --all

/usr/bin/git commit -m "Baseline Baby"

/usr/bin/git push -u origin main

${HOME}/application/customise/UnCustomiseBackupByApplication.sh

/bin/echo ""
/bin/echo "==================================================================================================================================="
/bin/echo "I consider your baseline to be complete you should verify the repository ${baseline_name}-webroot-sourcecode-baseline with ${REPOSITORY_PROVIDER} for user: ${APPLICATION_REPOSITORY_USERNAME}" 
/bin/echo "==================================================================================================================================="

/bin/rm -r ${HOME}/backups/${baseline_name}/*

exit 0

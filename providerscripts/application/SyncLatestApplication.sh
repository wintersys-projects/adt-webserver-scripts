#!/bin/sh
###########################################################################################################
# Description: When we build from a snapshot it is probable that the snapshot was taken quite some time
# before now and so the code on the snapshot will be stale compared to what we have as our backups in our
# repositories, so, when we build from a snapshot, we do a sync with our repoistories or datastore to make
# sure that our codebase is up to date even when we are building from a snapshot which is a bit long in the tooth
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

if ( [ -f ${HOME}/runtime/APPLICATION_SYNCED ] )
then
    exit
fi

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] )
then
    exit
fi

HOME="`/bin/ls -ld /home/X*X | /usr/bin/awk '{print $NF}'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
BUILD_ARCHIVE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"

application_repository_name="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-${BUILD_ARCHIVE_CHOICE}-${BUILD_IDENTIFIER}"

if ( [ -f /var/www/html/.htaccess ] )
then
    /bin/mv /var/www/html/.htaccess /tmp
fi

/bin/mv /var/www/html /var/www/html.$$
/bin/mkdir -p /var/www/html
/bin/chmod 755 /var/www/html
/bin/chown www-data:www-data /var/www/html
cd /var/www/html

synced="0"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:0`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:1`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_USERNAME} ${application_repository_name} 2>/dev/null`" != "" ] )
    then
        /usr/bin/git init
        /bin/chown -R www-data:www-data /var/www/html/.git
        ${HOME}/providerscripts/git/GitClone.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_USERNAME} ${application_repository_name} > /dev/null 2>&1
        /bin/mv /var/www/html/${application_repository_name}/* /var/www/html
        /bin/rm -r /var/www/html/${application_repository_name}

        if ( [ "`${HOME}/providerscripts/application/configuration/CheckIfApplicationIsInstalled.sh`" = "1" ] )
        then
            if ( [ "`${HOME}/providerscripts/application/configuration/VerifyApplicationType.sh`" = "1" ] )
            then
                synced="1"
            fi
        fi
    fi
    if ( [ "${synced}" = "0" ] && ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:1`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:2`" = "1" ] ) )
    then
        cd ${HOME}
        ${HOME}/providerscripts/datastore/GetFromDatastore.sh "${DATASTORE_CHOICE}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${BUILD_ARCHIVE_CHOICE}/applicationsourcecode.tar.gz"
        if ( [ -f ${HOME}/applicationsourcecode.tar.gz ] )
        then
            /bin/tar xvfz ${HOME}/applicationsourcecode.tar.gz
            /bin/mv ${HOME}/tmp/backup/* /var/www/html
            /bin/rm -rf ${HOME}/tmp
        fi
        
        if ( [ "`${HOME}/providerscripts/application/configuration/CheckIfApplicationIsInstalled.sh`" = "1" ] )
        then
            if ( [ "`${HOME}/providerscripts/application/configuration/VerifyApplicationType.sh`" = "1" ] )
            then
                synced="1"
            fi
        fi
    fi
fi

if ( [ "${synced}" = "0" ] )
then
     #Couldn't find any newer backups to revert back to the original
     /bin/mkdir -p /var/www/html.$$.$$
     /bin/mv /var/www/html/* /var/www/html.$$.$$
     /bin/mv /var/www/html.$$/* /var/www/html
     /bin/rm -r /var/www/html.$$ /var/www/html.$$.$$
     
     if ( [ "`${HOME}/providerscripts/application/configuration/CheckIfApplicationIsInstalled.sh`" = "1" ] )
     then
          if ( [ "`${HOME}/providerscripts/application/configuration/VerifyApplicationType.sh`" = "1" ] )
          then
             synced="1"
          fi
     fi    
else
     /bin/rm -r /var/www/html.$$
fi

if ( [ "${synced}" = "1" ] )
then
   /bin/touch ${HOME}/runtime/APPLICATION_SYNCED
else
    ${HOME}/providerscripts/email/SendEmail.sh "HAD TROUBLE SYNCING THE APPLICATION" "You might want to look into this couldn't validly synchronise the latest version of your application" "ERROR"
fi

if ( [ -f /tmp/.htaccess ] )
then
    /bin/mv /tmp/.htaccess /var/www/html
fi

/bin/chown -R www-data:www-data /var/www/html/*
/usr/bin/find /var/www/html/ -type d -print -exec chmod 755 {} \;
/usr/bin/find /var/www/html/ -type f -print -exec chmod 644 {} \;

${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "APPLICATION_DB_CONFIGURED"
${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "UPDATE*"
${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "DB*"


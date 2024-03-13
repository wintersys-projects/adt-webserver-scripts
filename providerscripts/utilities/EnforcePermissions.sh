#!/bin/sh
###############################################################################################
# Description: This script will set the permissions correctly for the webroot. It is called periodically
# from cron to make sure that any new additions to the webroot filesystem also have the correct permissions.
# Author: Peter Winter
# Date: 07/01/2017
################################################################################################
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
##########################################################################################
##########################################################################################
#set -x

SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"

/bin/chmod 755 /var/www/html
/bin/chmod 400 /var/www/html/.htaccess
/bin/chmod -R 700 ${HOME}/.ssh/*
/bin/chown ${SERVER_USER}:root ${HOME}/.ssh
/bin/chmod 400 ${HOME}/super/Super.sh


if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PERSISTASSETSTOCLOUD:0`" = "1" ] )
then
    /bin/chown -R www-data:www-data /var/www/html/${file}
    /usr/bin/find /var/www/html/${file} -type d -print -exec chmod 755 {} \;
    /usr/bin/find /var/www/html/${file} -type f -print -exec chmod 644 {} \;
else
    directoriestomiss="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"

    for file in `/bin/ls /var/www/html`
    do
       for directory in ${directoriestomiss}
       do
           for listable_file in `/bin/echo ${file} | /bin/grep  -v ${directory}`
           do
               if ( [ "`/bin/echo ${directoriestomiss} | /bin/grep ${listable_file}`" = "" ] )
               then
                   list_of_files="${list_of_files} ${listable_file}"
               fi
           done
       done
    done

    list_of_files="`/bin/echo ${list_of_files} | /usr/bin/xargs -n1 | /usr/bin/sort -u | /usr/bin/xargs`"

    for file in ${list_of_files}  
    do
        /bin/chown -R www-data:www-data /var/www/html/${file}
    done

    for file in ${list_of_files}
    do
        /usr/bin/find /var/www/html/${file} -type d -print -exec chmod 755 {} \;
        /usr/bin/find /var/www/html/${file} -type f -print -exec chmod 644 {} \;
    done
fi

/bin/chmod 755 /var/www/html
/bin/chown www-data:www-data /var/www/html


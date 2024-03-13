#!/bin/sh
#####################################################################################
# Description: If your application requires any post processing to be performed, then,
# this is the place to put it. Post processing is considered to be any processing which
# is required after the application is considered installed. This is the post processing
# for a joomla install. If you examine the code, you will find that this script is called
# from the build client over ssh once it considers that the application has been fully installed.
#   ***********IMPORTANT*****************
#   These post processing scripts are not run using sudo as is normally the case, this is because
#   of issues with stdin and so on. So if a command requires privilege then sudo must be used
#   on a command by command basis. This is true for all PerformPostProcessing Scripts
#   ***********IMPORTANT*****************
# Author: Peter Winter
# Date: 04/01/2017
###############################################################################################
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
#####################################################################################
#####################################################################################
set -x

#Setup operational directories if needed
if ( [ ! -d ${HOME}/logs ] )
then
    /bin/mkdir ${HOME}/logs
fi

#OUT_FILE="processing-`/bin/date | /bin/sed 's/ //g'`"
#exec 1>>${HOME}/logs/${OUT_FILE}
#ERR_FILE="processing-`/bin/date | /bin/sed 's/ //g'`"
#exec 2>>${HOME}/logs/${ERR_FILE}

SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

while ( [ ! -f ${HOME}/runtime/APPLICATION_DB_GENERATED ] )
do
     /bin/sleep 10
     if ( [ "`/home/${SERVER_USER}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
     then
         if ( [ -f ${HOME}/runtime/VIRGINCONFIGSET ] )
         then
             php_version="`/usr/bin/php -v | /bin/grep "^PHP" | /usr/bin/awk '{print $2}' | /usr/bin/awk -F'.' '{print $1,$2}' | /bin/sed 's/ /\./g'`"
             php_ini="/etc/php/${php_version}/cli/php.ini"

             /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /bin/sed -i "s/^;max_input_vars.*/max_input_vars=6000/g" ${php_ini}
             /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /bin/sed -i "s/^max_input_vars.*/max_input_vars=6000/g" ${php_ini}

             /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/bin/php /var/www/html/moodle/admin/cli/install_database.php --lang=en --adminuser="admin123" --adminpass="changeme17832" --agree-license
             if ( [ "$?" = "0" ] )
             then
                 /bin/touch ${HOME}/runtime/APPLICATION_DB_GENERATED
             fi
         fi
     else
         /bin/touch ${HOME}/runtime/APPLICATION_DB_GENERATED
     fi
done

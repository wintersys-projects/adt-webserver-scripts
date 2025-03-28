#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: This script will enforce filesystem permissions and can be modified according
# to how you want your server secured
#######################################################################################
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
########################################################################################
########################################################################################
#set -x

HOME="`/bin/cat /home/homedir.dat`"

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

/bin/chmod 755 /var/www/html
/bin/chmod 400 /var/www/html/.htaccess

/usr/bin/find ${HOME} -type d -exec chmod 755 {} \;
/usr/bin/find ${HOME} -type f -exec chmod 750 {} \;
/usr/bin/find ${HOME} -type d -exec chown ${SERVER_USER}:root {} \;
/usr/bin/find ${HOME} -type f -exec chown ${SERVER_USER}:root {} \;
/bin/chmod 700 ${HOME}/.ssh
/bin/chmod 644 ${HOME}/.ssh/authorized_keys
/bin/chmod 600 ${HOME}/.ssh/id_*
/bin/chmod 644 ${HOME}/.ssh/id_*pub


directories_to_miss=""
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh PERSISTASSETSTOCLOUD:1`" = "1" ] )
then
    directories_to_miss="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
fi

exclude_command=""

if ( [ "${directories_to_miss}" != "" ] )
then
    for directory in ${directories_to_miss}
    do
        exclude_command="${exclude_command} ! -path '/var/www/html/${directory}/* "
    done
fi

for node in `/usr/bin/find /var/www/html ! -user www-data -o ! -group www-data ${exclude_command}`
do
    /bin/chown www-data:www-data ${node}
    if ( [ -d ${node} ] )
    then
        /bin/chmod 755 ${node}
    fi
    if ( [ -f ${node} ] )
    then
        /bin/chmod 644 ${node}
    fi
done

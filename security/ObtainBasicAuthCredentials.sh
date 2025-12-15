#!/bin/sh
#################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: If a machine has been allowed access by an authenticator machine
# then allow its ip address through the firewall now
#################################################################################
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
#set -x

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SSH_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
HOST="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh authenticatorip/* | /usr/bin/tr '\n' ' '`"
BUILD_IDENTIFIER="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
HOME="`/bin/cat /home/homedir.dat`"

basic_auth_file=""
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:APACHE`" = "1" ] )
then
        basic_auth_file="/etc/apache2/.htpasswd"
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:NGINX`" = "1" ] )
then
        basic_auth_file="/etc/nginx/.htpasswd"
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:LIGHTTPD`" = "1" ] )
then
        basic_auth_file="/etc/lighttpd/.htpasswd"
fi

if ( [ ! -d ${HOME}/runtime/authenticator ] )
then
        /bin/mkdir ${HOME}/runtime/authenticator
fi

new_user_details="0"
for host in ${HOST}
do
        /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -P ${SSH_PORT} ${SERVER_USER}@${host}:${HOME}/runtime/authenticator/basic-auth.dat ${HOME}/runtime/authenticator/basic-auth.dat.new
        for userdetails in `/bin/cat ${HOME}/runtime/authenticator/basic-auth.dat.new`
        do
                if ( [ "`/bin/grep ^${userdetails} ${basic_auth_file}`" = "" ] )
                then
                        new_user_details="1"
                        username="`/bin/echo ${userdetails} | /usr/bin/awk -F':' '{print $1}'`"
                        if ( [ -f ${basic_auth_file} ] )
                        then
                                /bin/sed -i "/^${username}/d" ${basic_auth_file}
                        fi
                        /bin/echo ${userdetails} >> ${basic_auth_file}
                fi
        done
done

if ( [ -f ${HOME}/runtime/authenticator/basic-auth.dat.new ] )
then
        /bin/rm ${HOME}/runtime/authenticator/basic-auth.dat.new
fi

/bin/chmod 600 ${basic_auth_file}
/bin/chown www-data:www-data ${basic_auth_file}

if ( [ "${new_user_details}" = "1" ] )
then
        ${HOME}/providerscripts/webserver/ReloadWebserver.sh
fi

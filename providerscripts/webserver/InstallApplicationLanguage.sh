#!/bin/sh
###################################################################################
# Description: This will install the selected application language
# Date: 18/11/2016
# Author: Peter Winter
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
###################################################################################
###################################################################################
#set -x

application_language="$1"

if ( [ "${application_language}" = "PHP" ] )
then
    BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
    
    if ( [ "${BUILDOS}" = "ubuntu" ] )
    then
        ${HOME}/installscripts/InstallPHPBase.sh
    elif ( [ "${BUILDOS}" = "debian" ] )
    then
        ${HOME}/installscripts/InstallPHPBase.sh
    fi

    php_version="`/usr/bin/php -v | /bin/grep "^PHP" | /usr/bin/awk '{print $2}' | /usr/bin/awk -F'.' '{print $1,$2}' | /bin/sed 's/ /\./g'`"
    php_ini="/etc/php/${php_version}/fpm/php.ini"
    www_conf="/etc/php/${php_version}/fpm/pool.d/www.conf"

    /bin/sed -i "s/^;env/env/g" ${www_conf}

    port="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"
    if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" != "" ] )
    then
         /bin/sed -i "s/^listen =.*/listen = 127.0.0.1:${port}/g" ${www_conf}
         /bin/sed -i "s/^;listen.allowed_clients/listen.allowed_clients/" ${www_conf}

    else
        /bin/sed -i "s,^listen =.*,listen = /var/run/php${php_version}-fpm.sock,g" ${www_conf}
        /bin/sed -i "s/^;listen.mode/listen.mode/" ${www_conf}

    fi

    pool_settings="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "CONFIGPHPPOOL" "stripped" | /bin/sed 's/:/ /g'`"

    if ( [ "${pool_settings}" != "" ] )
    then
        setting=""
        for setting in ${pool_settings}
        do
            name="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
            /bin/sed -i "s/^${name} =.*/${setting}/" ${www_conf}
            /bin/sed -i "s/^${name}=.*/${setting}/" ${www_conf}
            /bin/sed -i "s/^;${name}=.*/${setting}/" ${www_conf}
            /bin/sed -i "s/^;${name} =.*/${setting}/" ${www_conf}
        done
    fi

    ini_settings="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "CONFIGPHPINI" "stripped" | /bin/sed 's/:/ /g'`"
    
    if ( [ "${ini_settings}" != "" ] )
    then
        setting=""
        for setting in ${ini_settings}
        do
            name="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
            setting="`/bin/echo "${setting}" | /bin/sed 's/|/:/g'`"
            /bin/sed -i "s%^${name} =.*%${setting}%" ${php_ini}
            /bin/sed -i "s%^${name}=.*%${setting}%" ${php_ini}
            /bin/sed -i "s%^;${name}=.*%${setting}%" ${php_ini}
            /bin/sed -i "s%^;${name} =.*%${setting}%" ${php_ini}
        done
    fi

    php_service="`/usr/sbin/service --status-all | /bin/grep php | /usr/bin/awk '{print $NF}'`"

    /usr/sbin/service ${php_service} restart

    if ( [ "`/bin/ps -ef | /bin/grep php | /bin/grep -v grep`" = "" ] )
    then
        /bin/echo "PHP hasn't started. Can't run without it, please investigate."
        exit
    fi
fi

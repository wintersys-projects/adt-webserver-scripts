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
set -x

APPLICATION_LANGUAGE="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"

if ( [ "${1}" != "" ] )
then
	buildos="${1}"
fi

if ( [ "${buildos}" = "" ] )
then
	BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
else 
	BUILDOS="${buildos}"
fi

if ( [ "${APPLICATION_LANGUAGE}" = "PHP" ] )
then
	BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
	PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"

	if ( [ "${BUILDOS}" = "ubuntu" ] )
	then
		${HOME}/installscripts/InstallPHPBase.sh
	elif ( [ "${BUILDOS}" = "debian" ] )
	then
		${HOME}/installscripts/InstallPHPBase.sh
	fi

	if ( [ ! -d /var/lib/php/session ] )
	then
		/bin/mkdir -p /var/lib/php/sessions
		/bin/chown -R www-data:www-data /var/lib/php
	fi

	php_ini="/etc/php/${PHP_VERSION}/fpm/php.ini"
	www_conf="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
	/bin/sed -i "s/^;env/env/g" ${www_conf}
	#private_ip="`${HOME}/utilities/processing/GetIP.sh`"

	port="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"
	if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" != "" ] )
	then
		/bin/sed -i "s/^listen =.*/listen = 127.0.0.1:${port}/g" ${www_conf}
		/bin/sed -i "s/^;listen.allowed_clients/listen.allowed_clients/" ${www_conf}
	else
		/bin/sed -i "s,^listen =.*,listen = /var/run/php${PHP_VERSION}-fpm.sock,g" ${www_conf}
		/bin/sed -i "s/^;listen.mode/listen.mode/" ${www_conf}
	fi
	pool_settings="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "CONFIGPHPPOOL" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/##/:/g'`"

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

	ini_settings="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "CONFIGPHPINI" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/##/:/g'`"

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

	${HOME}/utilities/processing/RunServiceCommand.sh php${PHP_VERSION}-fpm restart

	/usr/bin/php -v

	if ( [ "$?" != "0" ] )
	then
		/bin/echo "PHP hasn't started. Can't run without it, please investigate."
		exit
	else
		/bin/touch ${HOME}/runtime/installedsoftware/InstallApplicationLanguage.sh				
	fi
fi

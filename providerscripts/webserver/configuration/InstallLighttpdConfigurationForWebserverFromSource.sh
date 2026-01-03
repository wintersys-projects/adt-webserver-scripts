#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will configure an lighttpd based webserver machine for a source
# style build
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
####################################################################################
####################################################################################
#set -x

BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
NO_AUTHENTICATORS="`${HOME}/utilities/config/ExtractConfigValue.sh 'NOAUTHENTICATORS'`"
NO_REVERSE_PROXY="`${HOME}/utilities/config/ExtractConfigValue.sh 'NOREVERSEPROXY'`"
AUTHENTICATOR_TYPE="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHENTICATORTYPE'`"
VPC_IP_RANGE="`${HOME}/utilities/config/ExtractConfigValue.sh 'VPCIPRANGE'`"
BUILD_MACHINE_IP="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDMACHINEIP'`"
AUTH_SERVER_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHSERVERURL'`"


if ( [ -f /etc/php/${PHP_VERSION}/fpm/php.ini ] )
then
	/bin/sed -i "/cgi.fix_pathinfo/c\ cgi.fix_pathinfo=1" /etc/php/${PHP_VERSION}/fpm/php.ini
fi

if ( [ -f /etc/lighttpd/lighttpd.conf ] )
then
	/bin/rm /etc/lighttpd/lighttpd.conf
fi

if ( [ -f /var/www/html/index.lighttpd.html ] )
then
	/bin/rm /var/www/html/index.lighttpd.html
fi

if ( [ ! -d /var/cache/lighttpd/uploads ] )
then
	/bin/mkdir -p /var/cache/lighttpd/uploads
	/bin/chown -R www-data:www-data /var/cache/lighttpd
fi

if ( [ ! -d /var/cache/lighttpd/compress ] )
then
	/bin/mkdir -p /var/cache/lighttpd/compress
	/bin/chown www-data:www-data /var/cache/lighttpd/compress
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/lighttpd.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/lighttpd.conf /etc/lighttpd/lighttpd.conf
fi
if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/mimetypes.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/mimetypes.conf /etc/lighttpd/mimetypes.conf
fi
if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/modules.conf ] )
then
	if ( [ ! -f /etc/lighttpd/modules.conf ] )
	then
		/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/modules.conf /etc/lighttpd/modules.conf
	fi
fi     

if ( [ -f /etc/lighttpd/lighttpd.conf ] )
then
	port="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

	if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
	then
		if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/fastcgi_socket.conf ] )
		then
			/bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/fastcgi_socket.conf" -e "d}" /etc/lighttpd/lighttpd.conf
			/bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/lighttpd/lighttpd.conf
		fi
	else
		if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/fastcgi_port.conf ] )
		then
			/bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/fastcgi_port.conf" -e "d}" /etc/lighttpd/lighttpd.conf
			/bin/sed -i "s/XXXXPORTXXXX/${port}/" /etc/lighttpd/lighttpd.conf
		fi
	fi

	if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/rc.local ] )
	then
		/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/rc.local /etc/rc.local
	fi

	if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/lighttpd-service.conf ] )
	then
		/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/source/lighttpd-service.conf  /etc/systemd/system/rc-local.service		
	fi

	if ( [ "${NO_AUTHENTICATORS}" != "0" ] && [ "${AUTHENTICATOR_TYPE}" = "basic-auth" ] && [ "${NO_REVERSE_PROXY}" = "0" ] )
	then
		/bin/sed -i -e "/#XXXXBASIC-AUTHXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/repo/basic-auth.conf" -e "d}" /etc/lighttpd/lighttpd.conf
		VPC_IP_RANGE="`echo "${VPC_IP_RANGE}" | /usr/bin/awk -F'.' -v OFS='.' '{NF=NF-1; print $0}'`\."
		/bin/sed -i "s;XXXXVPC_IP_RANGEXXXX;${VPC_IP_RANGE};g" /etc/lighttpd/lighttpd.conf
		/bin/sed -i "s/XXXXBUILD_MACHINE_IPXXXX/${BUILD_MACHINE_IP}/g" /etc/lighttpd/lighttpd.conf
		/bin/sed -i "s/XXXXWEBSITE_URLXXXXX/${AUTH_SERVER_URL}/g" /etc/lighttpd/lighttpd.conf
		/bin/touch /etc/lighttpd/.htpasswd
	fi

	/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/lighttpd/lighttpd.conf
	export HOME="`/bin/cat /home/homedir.dat`"
	/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/lighttpd/lighttpd.conf

	/bin/chown root:root /etc/lighttpd/lighttpd.conf
	/bin/chmod 600 /etc/lighttpd/lighttpd.conf
	/bin/chown root:root /etc/lighttpd/modules.conf
	/bin/chmod 600 /etc/lighttpd/modules.conf

	/bin/echo "/etc/lighttpd/lighttpd.conf" > ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat

	config_settings="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:settings" "stripped" | /bin/sed -e 's/|.*//g' -e 's/:/ /g'`"

	for setting in ${config_settings}
	do
		setting_name="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
		/usr/bin/find /etc/lighttpd -name '*' -type f -exec sed -i "s#.*${setting_name}.*#${setting}#" {} +
	done
fi

${HOME}/utilities/processing/RunServiceCommand.sh lighttpd restart &
${HOME}/providerscripts/email/SendEmail.sh "THE LIGHTTPD WEBSERVER HAS BEEN INSTALLED" "Lighttpd webserver is installed and primed" "INFO"

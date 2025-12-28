#!/bin/sh
#####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will perform a base installation of Nginx from source. You are welcome
# to modify it to your needs.
#####################################################################################
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
##################################################################################
##################################################################################
#set -x

BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
BUILDOS_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOSVERSION'`"
APPLICATION_LANGUAGE="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"
APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
DNS_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
MOD_SECURITY="`${HOME}/utilities/config/ExtractConfigValue.sh 'MODSECURITY'`"
AUTHENTICATOR_TYPE="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHENTICATORTYPE'`"
NO_REVERSE_PROXY="`${HOME}/utilities/config/ExtractConfigValue.sh 'NOREVERSEPROXY'`"
NO_AUTHENTICATORS="`${HOME}/utilities/config/ExtractConfigValue.sh 'NOAUTHENTICATORS'`"
VPC_IP_RANGE="`${HOME}/utilities/config/ExtractConfigValue.sh 'VPCIPRANGE'`"
BUILD_MACHINE_IP="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDMACHINEIP'`"
AUTH_SERVER_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHSERVERURL'`"

/bin/mkdir /etc/nginx/cache 2>/dev/null

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
	/bin/rm /etc/nginx/sites-available/${WEBSITE_NAME}
fi

if ( [ -h /etc/nginx/sites-enabled/${WEBSITE_NAME} ] )
then
	/usr/bin/unlink /etc/nginx/sites-enabled/${WEBSITE_NAME}
fi

if ( [ -h /etc/nginx/sites-enabled/default ] )
then
	/usr/bin/unlink /etc/nginx/sites-enabled/default
fi

/bin/mkdir -p /etc/nginx/sites-available

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/site-available.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/site-available.conf /etc/nginx/sites-available/${WEBSITE_NAME}
	/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/nginx/sites-available/${WEBSITE_NAME}
	export HOME="`/bin/cat /home/homedir.dat`"
	/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/nginx/sites-available/${WEBSITE_NAME}
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/restrictions.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/restrictions.conf /etc/nginx
fi

/usr/bin/openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048


port="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
then
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/php_socket.conf ] )
	then
		/bin/sed -i -e "/#XXXXPHPSOCKETXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/php_socket.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
		/bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/nginx/sites-available/${WEBSITE_NAME}
	fi
else
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/php_port.conf ] )
	then
		/bin/sed -i -e "/#XXXXPHPPORTXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/php_port.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
		/bin/sed -i "s/#XXXXPORTMODEONXXXX//" /etc/nginx/sites-available/${WEBSITE_NAME}
		/bin/sed -i "s/XXXXPORTXXXX/${port}/" /etc/nginx/sites-available/${WEBSITE_NAME}
	fi
fi

if ( [ "${NO_AUTHENTICATORS}" != "0" ] && [ "${AUTHENTICATOR_TYPE}" = "basic-auth" ] && [ "${NO_REVERSE_PROXY}" = "0" ] )
then
	/bin/sed -i -e "/#XXXXBASIC-AUTHXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/basic-auth.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
	/bin/sed -i "s;XXXXVPC_IP_RANGEXXXX;${VPC_IP_RANGE};g" /etc/nginx/sites-available/${WEBSITE_NAME}
	/bin/sed -i "s/XXXXBUILD_MACHINE_IPXXXX/${BUILD_MACHINE_IP}/g" /etc/nginx/sites-available/${WEBSITE_NAME}
	/bin/sed -i "s/XXXXWEBSITE_URLXXXXX/${AUTH_SERVER_URL}/g" /etc/nginx/sites-available/${WEBSITE_NAME}
	/bin/touch /etc/nginx/.htpasswd
fi

if ( [ "${MOD_SECURITY}" = "1" ] && [ "${NO_REVERSE_PROXY}" = "0" ] )
then
	/bin/sed -i -e "/#XXXXMODSECURITYXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/modsecurity.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
fi

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
	/bin/chmod 600 /etc/nginx/sites-available/${WEBSITE_NAME}
	/bin/chown root:root /etc/nginx/sites-available/${WEBSITE_NAME}
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/nginx.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/nginx.conf /etc/nginx/nginx.conf

	if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
	then
		/bin/sed -i "s,XXXXCLOUDFLAREXXXX,include /etc/nginx/cloudflare;,g" /etc/nginx/nginx.conf
	else
		/bin/sed -i "s/XXXXCLOUDFLAREXXXX//g" /etc/nginx/nginx.conf
	fi
fi

if ( [ -f /etc/nginx/nginx.conf ] )
then
	/bin/chmod 600  /etc/nginx/nginx.conf
	/bin/chown root:root  /etc/nginx/nginx.conf
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/blockuseragents.rules ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/blockuseragents.rules /etc/nginx/blockuseragents.rules
	/bin/chmod 600  /etc/nginx/blockuseragents.rules
	/bin/chown root:root /etc/nginx/blockuseragents.rules
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/nginx-service.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/nginx-service.conf /etc/systemd/system/nginx.service
	/bin/chmod 600  /etc/systemd/system/nginx.service
	/bin/chown root:root /etc/systemd/system/nginx.service
fi

/usr/bin/systemctl enable nginx.service
/bin/chmod 640 /var/log/nginx/*
/bin/chown www-data:www-data /var/log/nginx/access.log /var/log/nginx/error.log

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/logrotate.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/logrotate.conf /etc/logrotate.d/nginx
fi

/bin/mkdir /etc/nginx/snippets

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/fastcgi-php.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/source/fastcgi-php.conf /etc/nginx/snippets/fastcgi-php.conf
	/bin/chmod 600  /etc/nginx/snippets/fastcgi-php.conf
	/bin/chown root:root /etc/nginx/snippets/fastcgi-php.conf
fi

#Activate it
if ( [ -f /etc/nginx/sites-available/default ] )
then
	/bin/rm /etc/nginx/sites-available/default
fi

if ( [ ! -d /etc/nginx/sites-enabled ] )
then
	/bin/mkdir -p /etc/nginx/sites-enabled
fi

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
	/bin/ln -s /etc/nginx/sites-available/${WEBSITE_NAME} /etc/nginx/sites-enabled/${WEBSITE_NAME}
fi

/bin/echo "/etc/nginx/sites-available/${WEBSITE_NAME}" > ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat

${HOME}/providerscripts/dns/TrustRemoteProxy.sh
${HOME}/utilities/processing/RunServiceCommand.sh nginx restart &
${HOME}/providerscripts/email/SendEmail.sh "THE NGINX WEBSERVER HAS BEEN INSTALLED" "Nginx webserver is installed and primed" "INFO"

#!/bin/sh
#################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will install a lighttpd configuration for an authenticator type
# machine from source
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
################################################################################
################################################################################
#set -x

HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_URL="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/[^.]*./auth./'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^.//' | /bin/sed 's/ /\./g'`"
WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
DNS_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
USER_EMAIL_DOMAIN="`${HOME}/utilities/config/ExtractConfigValue.sh 'USEREMAILDOMAIN'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
MOD_SECURITY="`${HOME}/utilities/config/ExtractConfigValue.sh 'MODSECURITY'`"
AUTHENTICATOR_TYPE="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHENTICATORTYPE'`"

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/online/source/nginx.conf /etc/nginx
/bin/chown www-data:www-data /etc/nginx/nginx.conf
/bin/chmod 644 /etc/nginx/nginx.conf

if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
then
	/bin/sed -i "s,XXXXCLOUDFLAREXXXX,include /etc/nginx/cloudflare;,g" /etc/nginx/nginx.conf
else
	/bin/sed -i "s/XXXXCLOUDFLAREXXXX//g" /etc/nginx/nginx.conf
fi

if ( [ ! -d /etc/nginx/sites-available ] )
then
	/bin/mkdir -p /etc/nginx/sites-available
fi

/bin/rm /etc/nginx/sites-enabled/* 2>/dev/null

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/online/source/site-available.conf /etc/nginx/sites-available/${WEBSITE_NAME}
/bin/chown www-data:www-data /etc/nginx/sites-available/${WEBSITE_NAME}
/bin/chmod 644 /etc/nginx/sites-available/${WEBSITE_NAME}

if ( [ "${MOD_SECURITY}" = "1" ] )
then
	/bin/sed -i -e "/#XXXXMODSECURITYXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/online/source/modsecurity.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
fi

/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/nginx/sites-available/${WEBSITE_NAME}
/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/nginx/sites-available/${WEBSITE_NAME}

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/online/source/blockuseragents.rules /etc/nginx/
/bin/chown www-data:www-data /etc/nginx/blockuseragents.rules
/bin/chmod 644 /etc/nginx/blockuseragents.rules

/usr/bin/openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

port="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
then
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/online/repo/php_socket.conf ] )
	then
		/bin/sed -i -e "/#XXXXPHPSOCKETXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/online/repo/php_socket.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
		/bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/nginx/sites-available/${WEBSITE_NAME}
	fi
else
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/online/repo/php_port.conf ] )
	then
		/bin/sed -i -e "/#XXXXPHPPORTXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/online/repo/php_port.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
		/bin/sed -i "s/#XXXXPORTMODEONXXXX//" /etc/nginx/sites-available/${WEBSITE_NAME}
		/bin/sed -i "s/XXXXPORTXXXX/${port}/" /etc/nginx/sites-available/${WEBSITE_NAME}
	fi
fi

if ( [ ! -d /etc/nginx/sites-enabled ] )
then
	/bin/mkdir -p /etc/nginx/sites-enabled
fi

/bin/ln -s /etc/nginx/sites-available/${WEBSITE_NAME} /etc/nginx/sites-enabled/${WEBSITE_NAME}

/bin/echo "/etc/nginx/sites-available/${WEBSITE_NAME}" > ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat

/bin/rm -r /var/www/html/* /var/www/html/.*
/bin/chown www-data:www-data /var/www/html
/bin/chmod 755 /var/www/html

if ( [ "${AUTHENTICATOR_TYPE}" = "firewall" ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/${AUTHENTICATOR_TYPE}/index.html /var/www/html/index.html
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/${AUTHENTICATOR_TYPE}/submit.php /var/www/html/submit.php
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/${AUTHENTICATOR_TYPE}/submit1.php /var/www/html/submit1.php
	/bin/chown www-data:www-data /var/www/html/*
	/bin/chmod 644 /var/www/html/*
	/bin/sed -i "s/XXXXUSEREMAILDOMAINXXXX/${USER_EMAIL_DOMAIN}/g" /var/www/html/index.html
	/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /var/www/html/index.html
fi






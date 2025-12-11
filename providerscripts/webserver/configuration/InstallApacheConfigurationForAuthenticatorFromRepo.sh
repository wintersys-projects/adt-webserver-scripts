#!/bin/sh
###########################################################################################################
# Description: This will install the apache configuration for an authentication machine from repo
# Author : Peter Winter
# Date: 17/05/2017
######################################################################################################
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

HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHSERVERURL'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^.//' | /bin/sed 's/ /\./g'`"
WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
DNS_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
USER_EMAIL_DOMAIN="`${HOME}/utilities/config/ExtractConfigValue.sh 'USEREMAILDOMAIN'`"
MOD_SECURITY="`${HOME}/utilities/config/ExtractConfigValue.sh 'MODSECURITY'`"
AUTHENTICATOR_TYPE="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHENTICATORTYPE'`"

/bin/rm /etc/apache2/sites-available/*

/usr/sbin/a2dismod mpm_prefork

apache_modules="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "APACHE:modules-list" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g' | /bin/sed 's/modules-list//g'`"
for module in ${apache_modules}
do
	/usr/sbin/a2enmod ${module}
	/usr/sbin/a2enconf ${module}
done

if ( [ -f /etc/apache2/ports.conf ] )
then
	/bin/sed -i 's/^Listen 80/#Listen 80/g' /etc/apache2/ports.conf
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
then
	/usr/sbin/a2enmod php${PHP_VERSION}-fpm
	/usr/sbin/a2enconf php${PHP_VERSION}-fpm
fi

/usr/bin/openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/apache/online/repo/apache2.conf /etc/apache2
/bin/chown www-data:www-data /etc/apache2/apache2.conf
/bin/chmod 644 /etc/apache2/apache2.conf

/bin/rm /etc/apache2/sites-enabled/* 2>/dev/null

if ( [ ! -d /etc/apache2/sites-available ] )
then
	/bin/mkdir -p /etc/apache2/sites-available
fi


/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/apache/online/repo/site-available.conf /etc/apache2/sites-available/${WEBSITE_NAME}.conf
/bin/chown www-data:www-data /etc/apache2/sites-available/${WEBSITE_NAME}.conf
/bin/chmod 644 /etc/apache2/sites-available/${WEBSITE_NAME}.conf

/bin/echo "/etc/apache2/sites-available/${WEBSITE_NAME}.conf" > ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat

/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf

port="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
then
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/apache/online/repo/fastcgi_socket.conf ] )
	then
		/bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/apache/online/repo/fastcgi_socket.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
		/bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	fi
else
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/apache/online/repo/fastcgi_port.conf ] )
	then
		/bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/apache/online/repo/fastcgi_port.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
		/bin/sed -i "s/XXXXPORTXXXX/${port}/" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	fi
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/apache/online/repo/htaccess.conf ] )
then
	if ( [ ! -d ${HOME}/runtime/overridehtaccess ] )
	then
		/bin/mkdir -p ${HOME}/runtime/overridehtaccess
	fi
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/apache/online/repo/htaccess.conf ${HOME}/runtime/overridehtaccess/htaccess.conf
fi

if ( [ "${MOD_SECURITY}" = "1" ] )
then
	/bin/sed -i -e "/#XXXXMODSECURITYXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/apache/online/repo/modsecurity.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
fi

/bin/sed -i "s/XXXXROOTDOMAINXXXX/${ROOT_DOMAIN}/" /etc/apache2/sites-available/${WEBSITE_NAME}.conf

if ( [ ! -d /etc/apache2/sites-enabled ] )
then
	/bin/mkdir -p /etc/apache2/sites-enabled
fi

/bin/ln -s /etc/apache2/sites-available/${WEBSITE_NAME}.conf /etc/apache2/sites-enabled/${WEBSITE_NAME}
/bin/chown -R www-data:www-data /etc/apache2

if ( [ -f /etc/apache2/conf-enabled/sec* ] )
then
	/usr/bin/unlink /etc/apache2/conf-enabled/sec*
fi

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
elif ( [ "${AUTHENTICATOR_TYPE}" = "basic-auth" ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/${AUTHENTICATOR_TYPE}/index.html /var/www/html/index.html
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/${AUTHENTICATOR_TYPE}/submit.php /var/www/html/submit.php
	/bin/chown www-data:www-data /var/www/html/*
	/bin/chmod 644 /var/www/html/*
fi

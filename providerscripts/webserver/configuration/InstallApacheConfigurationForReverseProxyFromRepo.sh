#!/bin/sh
###########################################################################################################
# Description : This will configure an apache based reverse proxy server
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
set -x

HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^.//' | /bin/sed 's/ /\./g'`"
WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
DNS_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
MOD_SECURITY="`${HOME}/utilities/config/ExtractConfigValue.sh 'MODSECURITY'`"

/usr/sbin/a2dismod mpm_prefork
/usr/sbin/a2enmod lbmethod_byrequests #definitely need this one

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

/usr/bin/openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/repo/apache2.conf /etc/apache2
/bin/chown www-data:www-data /etc/apache2/apache2.conf
/bin/chmod 644 /etc/apache2/apache2.conf

/bin/rm /etc/apache2/sites-enabled/* 2>/dev/null

if ( [ ! -d /etc/apache2/sites-available ] )
then
	/bin/mkdir -p /etc/apache2/sites-available
fi

/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/repo/site-available.conf /etc/apache2/sites-available/${WEBSITE_NAME}.conf
/bin/chown www-data:www-data /etc/apache2/sites-available/${WEBSITE_NAME}.conf
/bin/chmod 644 /etc/apache2/sites-available/${WEBSITE_NAME}.conf

/bin/echo "/etc/apache2/sites-available/${WEBSITE_NAME}.conf" > ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat

/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf

if ( [ -f ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/repo/htaccess.conf ] )
then
	if ( [ ! -d ${HOME}/runtime/overridehtaccess ] )
	then
		/bin/mkdir -p ${HOME}/runtime/overridehtaccess
	fi
	/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/repo/htaccess.conf ${HOME}/runtime/overridehtaccess/htaccess.conf
fi

if ( [ "${MOD_SECURITY}" = "1" ] )
then
	/bin/sed -i -e "/#XXXXMODSECURITYXXXX/{r ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/repo/modsecurity.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
fi

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

${HOME}/providerscripts/dns/TrustRemoteProxy.sh
${HOME}/providerscripts/email/SendEmail.sh "THE APACHE REVERSE PROXY HAS BEEN INSTALLED" "Apache reverse proxy is installed and primed" "INFO"

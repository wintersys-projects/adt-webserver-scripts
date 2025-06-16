#!/bin/sh
#################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will provide a base installation of Apache from repo. You are
# welcome to modify it to your needs.
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

BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^.//' | /bin/sed 's/ /\./g'`"
APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"

#You need to provide a mpm module to use in the buildsytles file even if it is mpm_prefork
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
	/usr/sbin/a2enconf php${PHP_VERSION}-fpm
fi

/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/apache2.conf /etc/apache2
/bin/chown www-data:www-data /etc/apache2/apache2.conf
/bin/chmod 644 /etc/apache2/apache2.conf

/bin/rm /etc/apache2/sites-enabled/* 2>/dev/null
/usr/sbin/a2dissite 000-default.conf

/bin/rm /etc/apache2/sites-available/*def* 2>/dev/null

/usr/bin/openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/site-available.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/site-available.conf /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	export HOME="`/bin/cat /home/homedir.dat`"
	/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/sed -i "s/XXXXROOTDOMAINXXXX/${ROOT_DOMAIN}/g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/chmod 600 /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/chown root:root /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/usr/sbin/a2ensite ${WEBSITE_NAME}
   	/bin/echo "/etc/apache2/sites-available/${WEBSITE_NAME}.conf" > ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat
fi

port="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
then
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/fastcgi.conf ] )
	then
		/bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/fastcgi.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
		/bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	fi
else
	/bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/fastcgi-port.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/sed -i "s/XXXXPORTXXXX/${port}/" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
fi

config_settings="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "APACHE:settings" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"

for setting in ${config_settings}
do
	setting_name="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
	setting_value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"
	/usr/bin/find /etc/apache2 -name '*' -type f -exec sed -i "s/^${setting_name}.*/${setting_name} ${setting_value}/" {} +
done

/bin/chown -R www-data:www-data /etc/apache2

#Activate it
/bin/echo "@reboot /bin/sleep 60 && /etc/init.d/apache2 restart" >> /var/spool/cron/crontabs/${SERVER_USER}

${HOME}/providerscripts/dns/TrustRemoteProxy.sh
${HOME}/providerscripts/email/SendEmail.sh "THE APACHE WEBSERVER HAS BEEN INSTALLED" "Apache webserver built from repositories is installed and primed" "INFO"

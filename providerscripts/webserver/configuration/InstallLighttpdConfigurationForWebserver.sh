#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will configure an lighttpd based webserver machine
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

HOME="`/bin/cat /home/homedir.dat`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION' | /usr/bin/tr '[:lower:]' '[:upper:]'`"
port="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $2}' | /bin/sed '/^$/d'`"

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

/bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" ${HOME}/providerscripts/webserver/configuration/application/lighttpd/lighttpd.conf
/bin/sed -i "s/XXXXPORTXXXX/${port}/" ${HOME}/providerscripts/webserver/configuration/application/lighttpd/lighttpd.conf
/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" ${HOME}/providerscripts/webserver/configuration/application/lighttpd/lighttpd.conf
/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" ${HOME}/providerscripts/webserver/configuration/application/lighttpd/lighttpd.conf

if ( [ -f ${HOME}/providerscripts/webserver/configuration/application/lighttpd/mimetypes.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/application/lighttpd/mimetypes.conf /etc/lighttpd/mimetypes.conf
fi

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" != "" ] )
then
	/bin/sed -i "s/#XXXXFASTCGIPORTXXXX//" ${HOME}/providerscripts/webserver/configuration/application/lighttpd/lighttpd.conf
else
	/bin/sed -i "s/#XXXXFASTCGISOCKETXXXX//" ${HOME}/providerscripts/webserver/configuration/application/lighttpd/lighttpd.conf
fi

/bin/sed -i "s/#XXXX${APPLICATION}XXXX//g" ${HOME}/providerscripts/webserver/configuration/application/lighttpd/lighttpd.conf
/bin/sed -i '/#XXXX.*/d' ${HOME}/providerscripts/webserver/configuration/application/lighttpd/lighttpd.conf
/bin/cat -s ${HOME}/providerscripts/webserver/configuration/application/lighttpd/lighttpd.conf > /etc/lighttpd/lighttpd.conf
/bin/chown root:root /etc/lighttpd/lighttpd.conf
/bin/chmod 600 /etc/lighttpd/lighttpd.conf
#/bin/chown root:root /etc/lighttpd/modules.conf
#/bin/chmod 600 /etc/lighttpd/modules.conf
/bin/echo "/etc/lighttpd/lighttpd.conf" > ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat

config_settings="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:settings" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"
for setting in ${config_settings}
do
	setting_name="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
	/usr/bin/find /etc/lighttpd -name '*' -type f -exec sed -i "s#.*${setting_name}.*#${setting}#" {} +
done

if ( [ ! -d /var/cache/lighttpd/uploads ] )
then
        /bin/mkdir -p /var/cache/lighttpd/uploads
        /bin/chown -R www-data:www-data /var/cache/lighttpd
fi

${HOME}/providerscripts/email/SendEmail.sh "THE LIGHTTPD WEBSERVER HAS BEEN INSTALLED" "Lighttpd webserver is installed and primed" "INFO"

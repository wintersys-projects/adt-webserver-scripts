#!/bin/sh
#################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will provide a base installation of Apache from source. You are
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

BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^.//' | /bin/sed 's/ /\./g'`"
APPLICATION="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"



#Install configuration values for apache
/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/httpd.conf /etc/apache2/httpd.conf
/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/envvars.conf /etc/apache2/envvars
#/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/magic.conf /etc/apache2/magic
/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/ports.conf /etc/apache2/ports.conf
#/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/httpd-ssl.conf /etc/apache2/httpd-ssl.conf
/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/init.d.conf /etc/init.d/apache2

#/bin/sed -i "s,XXXXFULLCHAINXXXX,${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem,g" /etc/apache2/httpd-ssl.conf
#/bin/sed -i "s,XXXXPRIVKEYXXXX,${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem,g" /etc/apache2/httpd-ssl.conf

/bin/sed -i "s/^#ServerRoot.*/ServerRoot \"\/etc\/apache2\"/g" /etc/apache2/httpd.conf

if ( [ ! -d /etc/apache2/sites-enabled ] )
then
	/bin/mkdir -p /etc/apache2/sites-enabled
fi

if ( [ ! -d /etc/apache2/sites-available ] )
then
	/bin/mkdir -p /etc/apache2/sites-available
fi

if ( [ ! -d /var/log/apache2 ] )
then
	/bin/mkdir -p /var/log/apache2
fi

/bin/chown www-data:www-data /var/log/apache2

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/site-available.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/site-available.conf /etc/apache2/sites-available/${WEBSITE_NAME}
	/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/apache2/sites-available/${WEBSITE_NAME}
	export HOME="`/bin/cat /home/homedir.dat`"
	/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/apache2/sites-available/${WEBSITE_NAME}
	/bin/sed -i "s/XXXXROOTDOMAINXXXX/${ROOT_DOMAIN}/g" /etc/apache2/sites-available/${WEBSITE_NAME}
	/bin/chmod 600 /etc/apache2/sites-available/${WEBSITE_NAME}
	/bin/chown root:root /etc/apache2/sites-available/${WEBSITE_NAME}
	/bin/ln -s /etc/apache2/sites-available/${WEBSITE_NAME} /etc/apache2/sites-enabled/${WEBSITE_NAME}
fi

if ( [ -f /etc/apache2/httpd.conf ] )
then
	/bin/sed -i "s/XXXXWEBSITEURLXXXX/ServerName ${WEBSITE_URL}/g" /etc/apache2/httpd.conf
	/bin/sed -i "s/XXXXAPPLICATIONNAMEXXXX/${WEBSITE_NAME}/g" /etc/apache2/httpd.conf
fi


port="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
then
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/fastcgi.conf ] )
	then
		/bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/fastcgi.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}
		/bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/apache2/sites-available/${WEBSITE_NAME}
	fi
else
	/bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/fastcgi-port.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}
	/bin/sed -i "s/XXXXPORTXXXX/${port}/" /etc/apache2/sites-available/${WEBSITE_NAME}
fi

#modules="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "APACHE:source" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/source//g' | /usr/bin/tac -s' '`"

#if ( [ "${modules}" != "" ] && [ -f /etc/apache2/httpd.conf ] )
#then
#	/bin/sed -i "/^LoadModule.*/d" /etc/apache2/httpd.conf
#	for module in ${modules}
#	do
#		/bin/sed -i "1i LoadModule ${module}_module  /usr/local/apache2/modules/mod_${module}.so" /etc/apache2/httpd.conf
#	done
#fi

config_settings="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "APACHE:settings" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"

for setting in ${config_settings}
do
        setting_name="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
        setting_value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"
        /usr/bin/find /etc/apache2 -name '*' -type f -exec sed -i "s/^${setting_name}.*/${setting_name} ${setting_value}/" {} +
done

/usr/bin/systemctl enable apache2.service
/usr/bin/systemctl start apache2.service &

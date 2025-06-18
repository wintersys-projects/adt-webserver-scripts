#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will perform a base installation of Lighttpd from repo. You are
# welcome to modify it to your needs.
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
BUILDOS_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOSVERSION'`"
APPLICATION_LANGUAGE="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"
APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
DNS_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"


if ( [ -f /etc/lighttpd/lighttpd.conf ] )
then
	/bin/rm /etc/lighttpd/lighttpd.conf
fi

if ( [ ! -f /var/www/cache/uploads ] )
then
	/bin/mkdir -p /var/www/cache/uploads
fi

if ( [ ! -d /var/cache/lighttpd/uploads ] )
then
	/bin/mkdir -p /var/cache/lighttpd/uploads
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/reverseproxy/lighttpd/online/repo/lighttpd.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/lighttpd/online/repo/lighttpd.conf /etc/lighttpd/lighttpd.conf
fi
if ( [ -f ${HOME}/providerscripts/webserver/configuration/reverseproxy/lighttpd/online/repo/mimetypes.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/lighttpd/online/repo/mimetypes.conf /etc/lighttpd/mimetypes.conf
fi
if ( [ -f ${HOME}/providerscripts/webserver/configuration/reverseproxy/lighttpd/online/repo/modules.conf ] )
then
	if ( [ ! -f /etc/lighttpd/modules.conf ] )
	then
		/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/lighttpd/online/repo/modules.conf /etc/lighttpd/modules.conf
	fi
fi    

if ( [ -f /etc/lighttpd/lighttpd.conf ] )
then
	/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/lighttpd/lighttpd.conf
	export HOME="`/bin/cat /home/homedir.dat`"
	/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/lighttpd/lighttpd.conf
	
	/bin/chown root:root /etc/lighttpd/lighttpd.conf
	/bin/chmod 600 /etc/lighttpd/lighttpd.conf
	/bin/chown root:root /etc/lighttpd/modules.conf
	/bin/chmod 600 /etc/lighttpd/modules.conf
  	/bin/echo "/etc/lighttpd/lighttpd.conf" > ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat
fi

lighttpd_modules="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:modules-list" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g' | /bin/sed 's/modules-list//'`"

if ( [ "${lighttpd_modules}" != "" ] )
then
	/bin/echo "server.modules = (" > /etc/lighttpd/modules.conf

	for module in ${lighttpd_modules}
	do
        	/bin/echo '"'${module}'",' >> /etc/lighttpd/modules.conf
	done

	/usr/bin/truncate -s -2 /etc/lighttpd/modules.conf
	/bin/echo "" >> /etc/lighttpd/modules.conf
	/bin/echo ")" >> /etc/lighttpd/modules.conf
fi

config_settings="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:settings" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"

for setting in ${config_settings}
do
        setting_name="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
        /usr/bin/find /etc/lighttpd -name '*' -type f -exec sed -i "s#.*${setting_name}.*#${setting}#" {} +
done

${HOME}/providerscripts/email/SendEmail.sh "THE LIGHTTPD REVERSE PROXY HAS BEEN INSTALLED" "Lighttpd reverse proxy is installed and primed" "INFO"

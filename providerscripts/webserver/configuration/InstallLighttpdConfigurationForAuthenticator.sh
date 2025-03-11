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
set -x

BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_URL="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/[^.]*./auth./'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"

if ( [ -f /etc/php/${PHP_VERSION}/fpm/php.ini ] )
then
        /bin/sed -i "/cgi.fix_pathinfo/c\ cgi.fix_pathinfo=1" /etc/php/${PHP_VERSION}/fpm/php.ini
fi

if ( [ -f /etc/lighttpd/lighttpd.conf ] )
then
        /bin/rm /etc/lighttpd/lighttpd.conf
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/lighttpd/lighttpd.conf ] )
then
        /bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf
fi
#if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/repo/mimetypes.conf ] )
#then
#       /bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/lighttpd/online/repo/mimetypes.conf /etc/lighttpd/mimetypes.conf
#fi
if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/lighttpd/modules.conf ] )
then
        if ( [ ! -f /etc/lighttpd/modules.conf ] )
        then
                /bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/lighttpd/modules.conf /etc/lighttpd/modules.conf
        fi
fi    

if ( [ -f /etc/lighttpd/lighttpd.conf ] )
then
        port="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

        if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
        then
                if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/lighttpd/fastcgi_socket.conf ] )
                then
                        /bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/lighttpd/fastcgi_socket.conf" -e "d}" /etc/lighttpd/lighttpd.conf
                        /bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/lighttpd/lighttpd.conf
                fi
        else
                if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/lighttpd/fastcgi_port.conf ] )
                then
                        /bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/lighttpd/fastcgi_port.conf" -e "d}" /etc/lighttpd/lighttpd.conf
                        /bin/sed -i "s/XXXXPORTXXXX/${port}/" /etc/lighttpd/lighttpd.conf
                fi
        fi

        /bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/lighttpd/lighttpd.conf
        export HOME="`/bin/cat /home/homedir.dat`"
        /bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/lighttpd/lighttpd.conf

        /bin/chown root:root /etc/lighttpd/lighttpd.conf
        /bin/chmod 600 /etc/lighttpd/lighttpd.conf
        /bin/chown root:root /etc/lighttpd/modules.conf
        /bin/chmod 600 /etc/lighttpd/modules.conf
fi

lighttpd_modules="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:modules-list" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g' | /bin/sed 's/modules-list//'`"

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

#config_settings="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:settings" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"

#for setting in ${config_settings}
#do
#        setting_name="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
#        /usr/bin/find /etc/lighttpd -name '*' -type f -exec sed -i "s#.*${setting_name}.*#${setting}#" {} +
#done

${HOME}/providerscripts/email/SendEmail.sh "THE LIGHTTPD WEBSERVER HAS BEEN INSTALLED" "Lighttpd webserver is installed and primed" "INFO"

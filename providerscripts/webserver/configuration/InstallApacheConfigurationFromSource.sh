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

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^.//' | /bin/sed 's/ /\./g'`"
APPLICATION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATION'`"

${HOME}/installscripts/InstallApache.sh ${BUILDOS}

#Install configuration values for apache
/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/httpd.conf /etc/apache2/httpd.conf
/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/envvars.conf /etc/apache2/envvars
/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/magic.conf /etc/apache2/magic
/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/ports.conf /etc/apache2/ports.conf
/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/httpd-ssl.conf /etc/apache2/httpd-ssl.conf
/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/init.d.conf /etc/init.d/apache2

/bin/sed -i "s,XXXXFULLCHAINXXXX,${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem,g" /etc/apache2/httpd-ssl.conf
/bin/sed -i "s,XXXXPRIVKEYXXXX,${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem,g" /etc/apache2/httpd-ssl.conf

/bin/sed -i "s/^#ServerRoot.*/ServerRoot \"\/etc\/apache2\"/g" /etc/apache2/httpd.conf

/bin/mkdir /etc/apache2/sites-enabled
#/bin/mkdir /etc/apache2/conf-enabled
/bin/mkdir /etc/apache2/sites-available
/bin/mkdir /var/log/apache2
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

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
then
    /bin/sed -i -e "/XXXXGATEWAYGUARDIANXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/gatewayguardian.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}
else
    /bin/sed -i "s/XXXXGATEWAYGUARDIANXXXX//g" /etc/apache2/sites-available/${WEBSITE_NAME}
fi

if ( [ -f /etc/apache2/httpd.conf ] )
then
    /bin/sed -i "s/XXXXWEBSITEURLXXXX/ServerName ${WEBSITE_URL}/g" /etc/apache2/httpd.conf
    /bin/sed -i "s/XXXXAPPLICATIONNAMEXXXX/${WEBSITE_NAME}/g" /etc/apache2/httpd.conf
fi



port="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
then
    if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/fastcgi.conf ] )
    then
        /bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/source/fastcgi.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}
        /bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/apache2/sites-available/${WEBSITE_NAME}
    fi
else
    /bin/sed -i "s/XXXXFASTCGIXXXX//g" /etc/apache2/sites-available/${WEBSITE_NAME}
    /bin/echo "ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:${port}/var/www/html/\$1 enablereuse=on" >> /etc/apache2/httpd.conf
fi

modules="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "APACHE" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/source//g' | /usr/bin/tac -s' '`"

if ( [ "${modules}" != "" ] )
then
    /bin/sed -i "/^LoadModule.*/d" /etc/apache2/httpd.conf
    for module in ${modules}
    do
        /bin/sed -i "1i LoadModule ${module}_module  /usr/local/apache2/modules/mod_${module}.so" /etc/apache2/httpd.conf
    done
fi

/bin/mv /etc/apache2/conf/magic.conf /etc/apache2/conf/magic.orig
/bin/ln -s /etc/apache2/magic /etc/apache2/conf/magic
/bin/mv /etc/apache2/conf/envvars /etc/apache2/conf/envvars.orig
/bin/ln -s /etc/apache2/envvars /etc/apache2/conf/envvars
/bin/mv /etc/apache2/conf/ports.conf /etc/apache2/conf/ports.conf.orig
/bin/ln -s /etc/apache2/ports.conf /etc/apache2/conf/ports.conf

/usr/sbin/update-rc.d apache2 defaults
/usr/bin/systemctl enable apache2.service
/usr/bin/systemctl start apache2.service &

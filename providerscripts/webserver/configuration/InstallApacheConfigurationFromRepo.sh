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

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^.//' | /bin/sed 's/ /\./g'`"
APPLICATION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATION'`"

${HOME}/installscripts/InstallApache.sh ${BUILDOS}

/usr/sbin/a2dismod mpm_prefork
/usr/sbin/a2enmod mpm_event
/usr/sbin/a2enmod ssl
/usr/sbin/a2enmod rewrite
/usr/sbin/a2enmod expires
/usr/sbin/a2enmod headers
/usr/sbin/a2enmod proxy
/usr/sbin/a2enmod proxy_http
/usr/sbin/a2enmod remoteip
/usr/sbin/a2enconf remoteip
/usr/sbin/a2enmod proxy_fcgi

/bin/sed -i 's/^Listen 80/#Listen 80/g' /etc/apache2/ports.conf

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
then
    /usr/sbin/a2enconf php${PHP_VERSION}-fpm
fi

/usr/sbin/a2dissite 000-default.conf
/bin/rm /etc/apache2/sites-available/*def*

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/site-available.conf ] )
then
    /bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/site-available.conf /etc/apache2/sites-available/${WEBSITE_NAME}.conf
    /bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
    export HOME="`/bin/cat /home/homedir.dat`"
    /bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
    /bin/sed -i "s/XXXXROOTDOMAINXXXX/${ROOT_DOMAIN}/g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
    /bin/chmod 600 /etc/apache2/sites-available/${WEBSITE_NAME}.conf
    /bin/chown root:root /etc/apache2/sites-available/${WEBSITE_NAME}.conf
    /usr/sbin/a2ensite /${WEBSITE_NAME}
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
then
    /bin/sed -i -e "/XXXXGATEWAYGUARDIANXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/gatewayguardian.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
else
    /bin/sed -i "s/XXXXGATEWAYGUARDIANXXXX//g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
fi

port="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
then
    if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/fastcgi.conf ] )
    then
        /bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/fastcgi.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
        /bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
    fi
else
    /bin/sed -i "s/XXXXFASTCGIXXXX//g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
  #  /bin/echo "ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:${port}/var/www/html/\$1 enablereuse=on" >> /etc/apache2/apache2.conf
    /bin/echo "ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:${port}/var/www/html/\$1" >> /etc/apache2/apache2.conf

fi

#Activate it
/bin/echo "@reboot /bin/sleep 60 && /etc/init.d/apache2 restart" >> /var/spool/cron/crontabs/${SERVER_USER}

${HOME}/providerscripts/dns/TrustRemoteProxy.sh

${HOME}/providerscripts/email/SendEmail.sh "THE APACHE WEBSERVER HAS BEEN INSTALLED" "Apache webserver built from repositories is installed and primed" "INFO"

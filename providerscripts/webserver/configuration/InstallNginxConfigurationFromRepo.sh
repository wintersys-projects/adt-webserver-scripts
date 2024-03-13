#!/bin/sh
#####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will perform a base installation of Nginx from repo. You are welcome
# to modify it to your needs.
#####################################################################################
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
##################################################################################
##################################################################################
#set -x

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
BUILDOS_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOSVERSION'`"
APPLICATION_LANGUAGE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"
APPLICATION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATION'`"
DNS_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DNSCHOICE'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"

${HOME}/installscripts/InstallNGINX.sh ${BUILDOS}

/bin/mkdir /etc/nginx/cache 2>/dev/null
/bin/rm /etc/nginx/sites-available/${WEBSITE_NAME}
/usr/bin/unlink /etc/nginx/sites-enabled/${WEBSITE_NAME}
/usr/bin/unlink /etc/nginx/sites-enabled/default
/bin/mkdir -p /etc/nginx/sites-available

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf ] )
then
    /bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf /etc/nginx/sites-available/${WEBSITE_NAME}
    /bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/nginx/sites-available/${WEBSITE_NAME}
    export HOME="`/bin/cat /home/homedir.dat`"
    /bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/nginx/sites-available/${WEBSITE_NAME}
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/gatewayguardian.conf ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
        /bin/sed -i -e "/XXXXGATEWAYGUARDIANXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/gatewayguardian.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
    else
        /bin/sed -i "s/XXXXGATEWAYGUARDIANXXXX//g" /etc/nginx/sites-available/${WEBSITE_NAME}
    fi
fi

port="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
then
    if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/fastcgi_socket.conf ] )
    then
        /bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/fastcgi_socket.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
        /bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/nginx/sites-available/${WEBSITE_NAME}
    fi
else
    if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/fastcgi_port.conf ] )
    then
        /bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/fastcgi_port.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
        /bin/sed -i "s/XXXXPORTXXXX/${port}/" /etc/nginx/sites-available/${WEBSITE_NAME}
    fi
fi

/bin/chmod 600 /etc/nginx/sites-available/${WEBSITE_NAME}
/bin/chown root:root /etc/nginx/sites-available/${WEBSITE_NAME}

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/nginx.conf ] )
then
    /bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/nginx.conf /etc/nginx/nginx.conf

    if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
    then
        /bin/sed -i "s,XXXXCLOUDFLAREXXXX,include /etc/nginx/cloudflare;,g" /etc/nginx/nginx.conf
    else
        /bin/sed -i "s/XXXXCLOUDFLAREXXXX//g" /etc/nginx/nginx.conf
    fi
fi

/bin/chmod 600  /etc/nginx/nginx.conf
/bin/chown root:root  /etc/nginx/nginx.conf

if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/blockuseragents.rules ] )
then
    /bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/blockuseragents.rules /etc/nginx/blockuseragents.rules
    /bin/chmod 600  /etc/nginx/blockuseragents.rules
    /bin/chown root:root /etc/nginx/blockuseragents.rules
fi

#Activate it
    
 /bin/rm /etc/nginx/sites-available/defau* 2>/dev/null

if ( [ ! -d /etc/nginx/sites-enabled ] )
then
    /bin/mkdir -p /etc/nginx/sites-enabled
fi

/bin/ln -s /etc/nginx/sites-available/${WEBSITE_NAME} /etc/nginx/sites-enabled/${WEBSITE_NAME}

${HOME}/providerscripts/dns/TrustRemoteProxy.sh

${HOME}/providerscripts/email/SendEmail.sh "THE NGINX WEBSERVER HAS BEEN INSTALLED" "Nginx webserver is installed and primed" "INFO"

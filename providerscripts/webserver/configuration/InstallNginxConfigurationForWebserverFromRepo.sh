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

BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
BUILDOS_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOSVERSION'`"
APPLICATION_LANGUAGE="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"
APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
APPLICATION="application"
DNS_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
AUTHENTICATOR_TYPE="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHENTICATORTYPE'`"
NO_REVERSE_PROXY="`${HOME}/utilities/config/ExtractConfigValue.sh 'NOREVERSEPROXY'`"
NO_AUTHENTICATORS="`${HOME}/utilities/config/ExtractConfigValue.sh 'NOAUTHENTICATORS'`"
VPC_IP_RANGE="`${HOME}/utilities/config/ExtractConfigValue.sh 'VPCIPRANGE'`"
BUILD_MACHINE_IP="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDMACHINEIP'`"
AUTH_SERVER_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHSERVERURL'`"


/bin/mkdir /etc/nginx/cache 2>/dev/null

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
	/bin/rm /etc/nginx/sites-available/${WEBSITE_NAME}
fi

if ( [ -h /etc/nginx/sites-enabled/${WEBSITE_NAME} ] )
then
	/usr/bin/unlink /etc/nginx/sites-enabled/${WEBSITE_NAME}
fi

if ( [ -h /etc/nginx/sites-enabled/default ] )
then
	/usr/bin/unlink /etc/nginx/sites-enabled/default
fi

if ( [ ! -d /etc/nginx/sites-available ] )
then
	/bin/mkdir -p /etc/nginx/sites-available
fi

/usr/bin/openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 &

HOME="`/bin/cat /home/homedir.dat`"
port="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
/bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
/bin/sed -i "s/XXXXPORTXXXX/${port}/" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
/bin/sed -i "s;XXXXVPC_IP_RANGEXXXX;${VPC_IP_RANGE};g" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
/bin/sed -i "s/XXXXBUILD_MACHINE_IPXXXX/${BUILD_MACHINE_IP}/g" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf

if ( [ "${NO_AUTHENTICATORS}" != "0" ] && [ "${AUTHENTICATOR_TYPE}" = "basic-auth" ] && [ "${NO_REVERSE_PROXY}" = "0" ] )
then
	/bin/sed -i "/#XXXXBASIC-AUTHXXXX//g" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
	/bin/touch /etc/nginx/.htpasswd
else
	/bin/sed -i "/#XXXXBASIC-AUTHXXXX/d" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
fi

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" != "" ] )
then
	/bin/sed -i "/##XXXXPHPSOCKETXXXX/d" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
	/bin/sed -i "s/#XXXXPHPPORTXXXX//g" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
	/bin/sed -i "s/#XXXXPORTMODEONXXXX//g" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
else
	/bin/sed -i "/#XXXXPORTMODEONXXXX/d" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
	/bin/sed -i "/#XXXXPHPPORTXXXX/d" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
	/bin/sed -i "s/#XXXXPHPVERSIONXXXX/${PHP_VERSION}/g" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf
	/bin/sed -i "s/#XXXXPHPSOCKETXXXX//g" ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf	
fi

/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/site-available.conf /etc/nginx/sites-available/${WEBSITE_NAME}

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
	/bin/chmod 600 /etc/nginx/sites-available/${WEBSITE_NAME}
	/bin/chown root:root /etc/nginx/sites-available/${WEBSITE_NAME}
fi

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

if ( [ -f /etc/nginx/nginx.conf ] )
then
	/bin/chmod 600  /etc/nginx/nginx.conf
	/bin/chown root:root  /etc/nginx/nginx.conf
fi

#if ( [ -f ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/blockuseragents.rules ] )
#then
#	/bin/cp ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/nginx/online/repo/blockuseragents.rules /etc/nginx/blockuseragents.rules
#	/bin/chmod 600  /etc/nginx/blockuseragents.rules
#	/bin/chown root:root /etc/nginx/blockuseragents.rules
#fi

#Activate it
if ( [ -f /etc/nginx/sites-available/default ] )
then
	/bin/rm /etc/nginx/sites-available/default
fi

if ( [ ! -d /etc/nginx/sites-enabled ] )
then
	/bin/mkdir -p /etc/nginx/sites-enabled
fi

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
	/bin/ln -s /etc/nginx/sites-available/${WEBSITE_NAME} /etc/nginx/sites-enabled/${WEBSITE_NAME}
fi

/bin/echo "/etc/nginx/sites-available/${WEBSITE_NAME}" > ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat

config_settings="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "NGINX:settings" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"

for setting in ${config_settings}
do
	setting_name="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
	setting_value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"
	/usr/bin/find /etc/nginx -name '*' -type f -exec sed -i "s/${setting_name}.*/${setting_name} ${setting_value};/" {} +
done

${HOME}/providerscripts/dns/TrustRemoteProxy.sh
${HOME}/providerscripts/email/SendEmail.sh "THE NGINX WEBSERVER HAS BEEN INSTALLED" "Nginx webserver is installed and primed" "INFO"

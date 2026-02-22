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

HOME="`/bin/cat /home/homedir.dat`"
DNS_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_URL="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/[^.]*./auth./'`"
USER_EMAIL_DOMAIN="`${HOME}/utilities/config/ExtractConfigValue.sh 'USEREMAILDOMAIN'`"
MOD_SECURITY="`${HOME}/utilities/config/ExtractConfigValue.sh 'MODSECURITY'`"
AUTHENTICATOR_TYPE="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHENTICATORTYPE'`"
port="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $2}' | /bin/sed '/^$/d'`"

if ( [ -d /etc/nginx/sites-available ] && [ "`/usr/bin/find /etc/nginx/sites-available -prune -empty 2>/dev/null`" = "" ] )
then
	/bin/rm /etc/nginx/sites-available/*
else
	/bin/mkdir -p /etc/nginx/sites-available
fi

if ( [ -d /etc/nginx/sites-enabled ] && [ "`/usr/bin/find /etc/nginx/sites-enabled -prune -empty 2>/dev/null`" = "" ] )
then
	/bin/rm /etc/nginx/sites-enabled/*
else
	/bin/mkdir -p /etc/nginx/sites-enabled
fi

/usr/bin/openssl dhparam -dsaparam -out /etc/ssl/certs/dhparam.pem 4096

/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" ${HOME}/providerscripts/webserver/configuration/application/nginx/site-available.conf
/bin/sed -i "s;XXXXHOMEXXXX;${HOME};g" ${HOME}/providerscripts/webserver/configuration/application/nginx/site-available.conf
/bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" ${HOME}/providerscripts/webserver/configuration/application/nginx/site-available.conf
/bin/sed -i "s/XXXXPORTXXXX/${port}/" ${HOME}/providerscripts/webserver/configuration/application/nginx/site-available.conf
/bin/sed -i "s/XXXXBUILD_MACHINE_IPXXXX/${BUILD_MACHINE_IP}/g" ${HOME}/providerscripts/webserver/configuration/application/nginx/site-available.conf


if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" != "" ] )
then
	/bin/sed -i "s/#XXXXPHPPORTXXXX//g" ${HOME}/providerscripts/webserver/configuration/application/nginx/site-available.conf
else
	/bin/sed -i "s/#XXXXPHPSOCKETXXXX//g" ${HOME}/providerscripts/webserver/configuration/application/nginx/site-available.conf	
fi

if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] )
then
	if ( [ "${MOD_SECURITY}" = "1" ] )
	then
		/bin/sed -i "s/#XXXXMODSECURITYXXXX//g" ${HOME}/providerscripts/webserver/configuration/application/nginx/site-available.conf
	fi
fi

/bin/sed -i "/#XXXX/d" ${HOME}/providerscripts/webserver/configuration/application/nginx/site-available.conf

/bin/cat -s ${HOME}/providerscripts/webserver/configuration/application/nginx/site-available.conf > /etc/nginx/sites-available/${WEBSITE_NAME}

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
	/bin/chmod 600 /etc/nginx/sites-available/${WEBSITE_NAME}
	/bin/chown root:root /etc/nginx/sites-available/${WEBSITE_NAME}
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/application/nginx/nginx.conf ] )
then
	if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
	then
		${HOME}/providerscripts/dns/TrustRemoteProxy.sh
		/bin/sed -i "s,#XXXXCLOUDFLAREXXXX,include /etc/nginx/cloudflare;,g" ${HOME}/providerscripts/webserver/configuration/application/nginx/nginx.conf
	fi
	/bin/cat -s ${HOME}/providerscripts/webserver/configuration/application/nginx/nginx.conf > /etc/nginx/nginx.conf
	/bin/chmod 600  /etc/nginx/nginx.conf
	/bin/chown root:root  /etc/nginx/nginx.conf
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

if ( [ -f ${HOME}/providerscripts/webserver/configuration/application/nginx/logrotate.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/application/nginx/logrotate.conf /etc/logrotate.d/nginx
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/application/nginx/nginx-service.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/application/nginx/nginx-service.conf /lib/systemd/system/nginx.service
	/bin/chmod 600  /lib/systemd/system/nginx.service
	/bin/chown root:root /lib/systemd/system/nginx.service
	${HOME}/utilities/processing/RunServiceCommand.sh nginx.service enable 
fi

if ( [ "${AUTHENTICATOR_TYPE}" = "firewall" ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/${AUTHENTICATOR_TYPE}/index.html /var/www/html/index.html
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/${AUTHENTICATOR_TYPE}/submit.php /var/www/html/submit.php
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/${AUTHENTICATOR_TYPE}/submit1.php /var/www/html/submit1.php
	/bin/chown www-data:www-data /var/www/html/*
	/bin/chmod 644 /var/www/html/*
	/bin/sed -i "s/XXXXUSEREMAILDOMAINXXXX/${USER_EMAIL_DOMAIN}/g" /var/www/html/index.html
	/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /var/www/html/index.html
elif ( [ "${AUTHENTICATOR_TYPE}" = "basic-auth" ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/${AUTHENTICATOR_TYPE}/index.html /var/www/html/index.html
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/${AUTHENTICATOR_TYPE}/submit.php /var/www/html/submit.php
	/bin/chown www-data:www-data /var/www/html/*
	/bin/chmod 644 /var/www/html/*
	/bin/sed -i "s/XXXXUSEREMAILDOMAINXXXX/${USER_EMAIL_DOMAIN}/g" /var/www/html/index.html
fi

${HOME}/utilities/processing/RunServiceCommand.sh nginx.service restart &
${HOME}/providerscripts/email/SendEmail.sh "THE NGINX WEBSERVER HAS BEEN INSTALLED" "Nginx authenticator is installed and primed" "INFO"

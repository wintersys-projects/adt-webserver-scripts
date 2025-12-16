#!/bin/sh
#################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will configure an apache based reverse proxy server for a
# source style build
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
MOD_SECURITY="`${HOME}/utilities/config/ExtractConfigValue.sh 'MODSECURITY'`"
NO_REVERSE_PROXY="`${HOME}/utilities/config/ExtractConfigValue.sh 'NOREVERSEPROXY'`"
NO_AUTHENTICATORS="`${HOME}/utilities/config/ExtractConfigValue.sh 'NOAUTHENTICATORS'`"
AUTHENTICATOR_TYPE="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHENTICATORTYPE'`"
VPC_IP_RANGE="`${HOME}/utilities/config/ExtractConfigValue.sh 'VPCIPRANGE'`"
BUILD_MACHINE_IP="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDMACHINEIP'`"
APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"

#Install configuration values for apache
/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/source/httpd.conf /etc/apache2/httpd.conf
/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/source/envvars.conf /etc/apache2/envvars
/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/source/ports.conf /etc/apache2/ports.conf
/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/source/init.d.conf /etc/init.d/apache2

/bin/sed -i "s/^#ServerRoot.*/ServerRoot \"\/etc\/apache2\"/g" /etc/apache2/httpd.conf

if ( [ ! -d /var/www/html ] )
then
	/bin/mkdir -p /var/www/html
fi

if ( [ ! -d /var/run/apache2 ] )
then
	/bin/mkdir -p /var/run/apache2
fi

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

/usr/bin/openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

if ( [ -f ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/source/site-available.conf ] )
then
	/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/source/site-available.conf /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	export HOME="`/bin/cat /home/homedir.dat`"
	/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/sed -i "s/XXXXROOTDOMAINXXXX/${ROOT_DOMAIN}/g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/chmod 600 /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/chown root:root /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/ln -s /etc/apache2/sites-available/${WEBSITE_NAME}.conf /etc/apache2/sites-enabled/${WEBSITE_NAME}.conf
	/bin/echo "/etc/apache2/sites-available/${WEBSITE_NAME}.conf" > ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat
fi

if ( [ -f ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/repo/htaccess.conf ] )
then
	if ( [ ! -d ${HOME}/runtime/overridehtaccess ] )
	then
		/bin/mkdir -p ${HOME}/runtime/overridehtaccess
	fi
	/bin/cp ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/repo/htaccess.conf ${HOME}/runtime/overridehtaccess/htaccess.conf
fi

if ( [ "${NO_AUTHENTICATORS}" != "0" ] && [ "${AUTHENTICATOR_TYPE}" = "basic-auth" ] && [ "${NO_REVERSE_PROXY}" != "0" ] )
then
	/bin/sed -i -e "/#XXXXBASIC-AUTHXXXX/{r ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/apache/online/repo/basic-auth.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/sed -i "s/Require all granted/#Require all granted/g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/sed -i "s;XXXXVPC_IP_RANGEXXXX;${VPC_IP_RANGE};g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/sed -i "s/XXXXBUILD_MACHINE_IPXXXX/${BUILD_MACHINE_IP}/g" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
	/bin/echo "LoadModule auth_basic_module /usr/local/apache2/modules/mod_auth_basic.so" >> /etc/apache2/modules.conf
	/bin/echo "LoadModule authn_file_module /usr/local/apache2/modules/mod_authn_file.so" >> /etc/apache2/modules.conf
	/bin/echo "LoadModule authn_core_module /usr/local/apache2/modules/mod_authn_core.so" >> /etc/apache2/modules.conf
	/bin/echo "LoadModule authz_host_module /usr/local/apache2/modules/mod_authz_host.so" >> /etc/apache2/modules.conf
	/bin/echo "LoadModule authz_user_module /usr/local/apache2/modules/mod_authz_user.so" >> /etc/apache2/modules.conf
	/bin/echo "LoadModule lbmethod_byrequests_module /usr/local/apache2/modules/mod_lbmethod_byrequests.so" >> /etc/apache2/modules.conf
	/bin/echo "LoadModule proxy_balancer_module /usr/local/apache2/modules/mod_proxy_balancer.so" >> /etc/apache2/modules.conf
	/bin/touch /etc/apache2/.htpasswd
fi

if ( [ "${MOD_SECURITY}" = "1" ] )
then
	/bin/sed -i -e "/#XXXXMODSECURITYXXXX/{r ${HOME}/providerscripts/webserver/configuration/reverseproxy/apache/online/source/modsecurity.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
fi

config_settings="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "APACHE:settings" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"

for setting in ${config_settings}
do
	setting_name="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
	setting_value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"
	/usr/bin/find /etc/apache2 -name '*' -type f -exec sed -i "s/^${setting_name}.*/${setting_name} ${setting_value}/" {} +
done

/usr/bin/systemctl enable apache2.service
/usr/bin/systemctl start apache2.service &

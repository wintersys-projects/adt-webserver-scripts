#!/bin/sh

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURLORIGINAL'`"

basic_auth_file=""
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:APACHE`" = "1" ] )
then
	basic_auth_file="/etc/apache2/.htpasswd"
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:NGINX`" = "1" ] )
then
	basic_auth_file="/etc/nginx/.htpasswd"
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:LIGHTTPD`" = "1" ] )
then
	basic_auth_file="/etc/lighttpd/.htpasswd"
fi

if ( [ ! -d ${HOME}/runtime/authenticator ] )
then
	/bin/mkdir -p ${HOME}/runtime/authenticator 
fi

/bin/touch ${HOME}/runtime/authenticator/basic-auth.dat

if ( [ -f /tmp/basic-auth.dat ] )
then
	/bin/mv /tmp/basic-auth.dat ${HOME}/runtime/authenticator/basic-auth.dat.$$
fi

for userdetails in `/bin/cat ${HOME}/runtime/authenticator/basic-auth.dat.$$`
do
	username="`/bin/echo ${userdetails} | /usr/bin/awk -F':' '{print $1}'`"
	password="`/bin/echo ${userdetails} | /usr/bin/awk -F':' '{print $2}'`"
	
	if ( [ ! -f ${basic_auth_file} ] )
	then
		/usr/bin/htpasswd -b -c ${basic_auth_file} ${username} ${password}
	else
		/usr/bin/htpasswd -b ${basic_auth_file} ${username} ${password}
	fi
fi


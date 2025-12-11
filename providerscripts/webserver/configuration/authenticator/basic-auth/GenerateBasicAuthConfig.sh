#!/bin/sh

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURLORIGINAL'`"

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
	
	if ( [ ! -f /etc/apache2/.htpasswd ] )
	then
		/usr/bin/htpasswd -b -c /etc/apache2/.htpasswd ${username} ${password}
	else
		/usr/bin/htpasswd -b /etc/apache2/.htpasswd ${username} ${password}
	fi
fi


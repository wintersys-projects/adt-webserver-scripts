HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^.//' | /bin/sed 's/ /\./g'`"
WEBSITE_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
DNS_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/nginx.conf /etc/nginx
/bin/chown www-data:www-data /etc/nginx/nginx.conf
/bin/chmod 644 /etc/nginx/nginx.conf

if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
then
  /bin/sed -i "s,XXXXCLOUDFLAREXXXX,include /etc/nginx/cloudflare;,g" /etc/nginx/nginx.conf
else
  /bin/sed -i "s/XXXXCLOUDFLAREXXXX//g" /etc/nginx/nginx.conf
fi

if ( [ ! -d /etc/nginx/sites-available ] )
then
  /bin/mkdir -p /etc/nginx/sites-available
fi

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/site-available.conf /etc/nginx/sites-available/${WEBSITE_NAME}
/bin/chown www-data:www-data /etc/nginx/sites-available/${WEBSITE_NAME}
/bin/chmod 644 /etc/nginx/sites-available/${WEBSITE_NAME}

/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/nginx/sites-available/${WEBSITE_NAME}
/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/nginx/sites-available/${WEBSITE_NAME}

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/blockuseragents.rules /etc/nginx/
/bin/chown www-data:www-data /etc/nginx/blockuseragents.rules
/bin/chmod 644 /etc/nginx/blockuseragents.rules

port="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
then
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/fastcgi_socket.conf ] )
	then
		/bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/fastcgi_socket.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
		/bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/nginx/sites-available/${WEBSITE_NAME}
	fi
else
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/fastcgi_port.conf ] )
	then
		/bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/fastcgi_port.conf" -e "d}" /etc/nginx/sites-available/${WEBSITE_NAME}
		/bin/sed -i "s/XXXXPORTXXXX/${port}/" /etc/nginx/sites-available/${WEBSITE_NAME}
	fi
fi

if ( [ ! -d /etc/nginx/sites-enabled ] )
then
  /bin/mkdir -p /etc/nginx/sites-enabled
fi

/bin/ln -s /etc/nginx/sites-available/${WEBSITE_NAME} /etc/nginx/sites-enabled/${WEBSITE_NAME}

/bin/rm -r /var/www/html/*
/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/index.php /var/www/html/index.php
/bin/chown www-data:www-data /var/www/html/index.php
/bin/chmod 644 /var/www/html/index.php
/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /var/www/html/index.php
/bin/sed -i "s/XXXXROOTDOMAINXXXX/${ROOT_DOMAIN}/g" /var/www/html/index.php


HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
DNS_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"

/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/sites-available.conf
/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/sites-available.conf

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

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/sites-available.conf /etc/nginx/sites-available/authenticator.conf
/bin/chown www-data:www-data /etc/nginx/sites-available/authenticator.conf
/bin/chmod 644 /etc/nginx/sites-available/authenticator.conf

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/blockuseragents.rules /etc/nginx/
/bin/chown www-data:www-data /etc/nginx/blockuseragents.rules
/bin/chmod 644 /etc/nginx/blockuseragents.rules

if ( [ ! -d /etc/nginx/sites-enabled ] )
then
  /bin/mkdir -p /etc/nginx/sites-enabled
fi

/bin/ln -s ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/sites-available.conf /etc/nginx/sites-enabled/authenticator.conf



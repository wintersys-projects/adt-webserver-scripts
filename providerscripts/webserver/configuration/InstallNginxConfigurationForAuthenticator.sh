
HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/sites-available.conf
/bin/sed -i "s/XXXXHOMEXXXX/${HOME}/g" ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/sites-available.conf

if ( [ ! -d /etc/nginx/sites-available ] )
then
  /bin/mkdir -p /etc/nginx/sites-available
fi

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/sites-available.conf /etc/nginx/sites-available
/bin/chown www-data:www-data /etc/nginx/sites-available/authenticator.conf
/bin/chmod 644 /etc/nginx/sites-available/authenticator.conf

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/blockuseragents.rules /etc/nginx/
/bin/chown www-data:www-data /etc/nginx/sites-available/blockuseragents.rules
/bin/chmod 644 /etc/nginx/sites-available/blockuseragents.rules

if ( [ ! -d /etc/nginx/sites-enabled ] )
then
  /bin/mkdir -p /etc/nginx/sites-enabled
fi

/bin/ln -s ${HOME}/providerscripts/webserver/configuration/authenticator/nginx/sites-available.conf /etc/nginx/sites-enabled/authenticator.conf



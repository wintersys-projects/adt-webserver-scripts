HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^.//' | /bin/sed 's/ /\./g'`"
WEBSITE_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
DNS_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/apache/apache2.conf /etc/apache2
/bin/chown www-data:www-data /etc/apache2/apache.conf
/bin/chmod 644 /etc/apache2/apache.conf


if ( [ ! -d /etc/apache2/sites-available ] )
then
  /bin/mkdir -p /etc/apache2/sites-available
fi

/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/apache/site-available.conf /etc/apache2/sites-available/${WEBSITE_NAME}
/bin/chown www-data:www-data /etc/apache2/sites-available/${WEBSITE_NAME}
/bin/chmod 644 /etc/apache2/sites-available/${WEBSITE_NAME}

/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /etc/apache2/sites-available/${WEBSITE_NAME}
/bin/sed -i "s,XXXXHOMEXXXX,${HOME},g" /etc/apache2/sites-available/${WEBSITE_NAME}

port="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ "`/bin/echo ${port} | /bin/grep -o "^[0-9]*$"`" = "" ] )
then
        if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/apache/fastcgi_socket.conf ] )
        then
                /bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/apache/fastcgi_socket.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}
                /bin/sed -i "s/XXXXPHPVERSIONXXXX/${PHP_VERSION}/" /etc/apache2/sites-available/${WEBSITE_NAME}
        fi
else
        if ( [ -f ${HOME}/providerscripts/webserver/configuration/authenticator/apache/fastcgi_port.conf ] )
        then
                /bin/sed -i -e "/XXXXFASTCGIXXXX/{r ${HOME}/providerscripts/webserver/configuration/authenticator/apache/fastcgi_port.conf" -e "d}" /etc/apache2/sites-available/${WEBSITE_NAME}
                /bin/sed -i "s/XXXXPORTXXXX/${port}/" /etc/apache2/sites-available/${WEBSITE_NAME}
        fi
fi

if ( [ ! -d /etc/apache2/sites-enabled ] )
then
  /bin/mkdir -p /etc/apache2/sites-enabled
fi

/bin/ln -s /etc/apache2/sites-available/${WEBSITE_NAME} /etc/apache2/sites-enabled/${WEBSITE_NAME}

/bin/rm -r /var/www/html/*
/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/index.php /var/www/html/index.php
/bin/chown www-data:www-data /var/www/html/index.php
/bin/chmod 644 /var/www/html/index.php
/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g" /var/www/html/index.php
/bin/sed -i "s/XXXXROOTDOMAINXXXX/${ROOT_DOMAIN}/g" /var/www/html/index.php

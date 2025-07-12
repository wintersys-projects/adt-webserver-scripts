

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
	exit
fi

${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh wordpress_config.php ${HOME}/runtime/wordpress_config.php

if ( [ ! -f ${HOME}/runtime/wordpress_config.php ] )
then
  ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Unable to obtain the wordpress configuration from the datastore during application initiation" "ERROR"
fi

/usr/bin/php -ln ${HOME}/runtime/wordpress_config.php

if ( [ "$?" = "0" ] )
then
  /bin/cp ${HOME}/runtime/wordpress_config.php /var/www/html/wp-config.php
  /bin/chmod 600 /var/www/html/wp-config.php
  /bin/chown www-data:www-data /var/www/html/wp-config.php
  
  if ( [ ! -f /var/www/html/wp-config.php ] )
  then
    ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy wordpress configuration file to the live location during application initiation" "ERROR"
  else
    /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
  fi
  
else
  ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE MALFORMED" "The wordpress configuration file appears to be malformed during application initiation" "ERROR"
fi 



if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
	exit
fi

${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime/drupal_settings.php

if ( [ ! -f ${HOME}/runtime/drupal_settings.php ] )
then
  ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Unable to obtain the joomla configuration from the datastore during application initiation" "ERROR"
fi

/usr/bin/php -ln ${HOME}/runtime/drupal_settings.php

if ( [ "$?" = "0" ] )
then
  /bin/cp ${HOME}/runtime/drupal_settings.php /var/www/html/sites/default/settings.php
  /bin/chmod 600 /var/www/html/sites/default/settings.php
  /bin/chown www-data:www-data /var/www/html/sites/default/settings.php
  
  if ( [ ! -f /var/www/html/sites/default/settings.php ] )
  then
    ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"
  else
    /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
  fi
  
else
  ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE MALFORMED" "The joomla configuration file appears to be malformed during application initiation" "ERROR"
fi 

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
	exit
fi

${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh moodle_config.php  ${HOME}/runtime/joomla_configuration.php

if ( [ ! -f ${HOME}/runtime/joomla_configuration.php ] )
then
  ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Unable to obtain the joomla configuration from the datastore during application initiation" "ERROR"
fi

/usr/bin/php -ln ${HOME}/runtime/joomla_configuration.php

if ( [ "$?" = "0" ] )
then
  /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/config.php
  /bin/chmod 600 /var/www/html/config.php
  /bin/chown www-data:www-data /var/www/html/config.php
  
  if ( [ ! -f /var/www/html/config.php ] )
  then
    ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"
  else
    /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
  fi
  
else
  ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE MALFORMED" "The joomla configuration file appears to be malformed during application initiation" "ERROR"
fi 

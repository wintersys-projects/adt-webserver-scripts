
if ( [ -f /var/www/html/installation/_J* ] )
then
	/bin/rm /var/www/html/installation/_J*
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
	exit
fi

${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime/joomla_configuration.php

if ( [ ! -f ${HOME}/runtime/joomla_configuration.php ] )
then
  ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Unable to obtain the joomla configuration from the datastore during application initiation" "ERROR"
fi

/usr/bin/php -ln ${HOME}/runtime/joomla_configuration.php

if ( [ "$?" = "0" ] )
then
  /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
  /bin/chmod 600 /var/www/html/configuration.php
  /bin/chown www-data:www-data /var/www/html/configuration.php
  if ( [ ! -f ${HOME}/runtime/joomla_configuration.php ] )
  then
    ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"
  fi
else
  ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE MALFORMED" "The joomla configuration file appears to be malformed during application initiation" "ERROR"
fi 

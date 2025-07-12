
${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime/joomla_configuration.php

if ( [ ! -f ${HOME}/runtime/joomla_configuration.php ] )
then

fi

/usr/bin/php -ln ${HOME}/runtime/joomla_configuration.php

if ( [ "$?" = "0" ] )
then
  /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
  /bin/chmod 600 /var/www/html/configuration.php
  /bin/chown www-data:www-data /var/www/html/configuration.php
else

fi 

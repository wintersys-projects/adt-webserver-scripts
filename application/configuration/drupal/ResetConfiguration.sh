if ( [ -f ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
  /bin/rm ${HOME}/runtime/INITIAL_CONFIG_SET 
fi

if ( [ -f /var/www/html/sites/default/settings.php ] )
then
  /bin/rm /var/www/html/sites/default/settings.php
fi

/bin/touch ${HOME}/runtime/CONFIGURATION_RESET_ACTIONED

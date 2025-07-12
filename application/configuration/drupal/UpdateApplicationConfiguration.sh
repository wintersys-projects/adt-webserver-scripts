if ( [ "`/usr/bin/find /var/www/html/sites/default/settings.php -cmin -1`" != "" ] )
then
        if ( [ "`/usr/bin/curl -m 2 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" != "" ] )
        then
                if ( [ -f ${HOME}/runtime/drupal_settings.php ] )
                then
                        /bin/mv ${HOME}/runtime/drupal_settings.php ${HOME}/runtime/drupal_settings.php.$$
                fi

                /bin/cp /var/www/html/sites/default/settings.php ${HOME}/runtime/drupal_settings.php
                /usr/bin/php -ln ${HOME}/runtime/drupal_settings.php
                if ( [ "$?" = "0" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/drupal_settings.php drupal_settings.php "no"
                fi
        fi
fi

/bin/sleep 20

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh drupal_settings.php`" -lt "130" ] && [ "`/usr/bin/find /var/www/html/sites/default/settings.php -cmin -1`" = "" ] )
then
       if ( [ -f ${HOME}/runtime/drupal_settings.php ] )
       then
        /bin/mv ${HOME}/runtime/drupal_settings.php ${HOME}/runtime/drupal_settings.php.$$
       fi
        if ( [ -f ${HOME}/runtime/drupal_settings.php ] )
        then
               ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh drupal_settings.php ${HOME}/runtime/drupal_settings.php
               /usr/bin/php -ln ${HOME}/runtime/drupal_settings.php
               if ( [ "$?" = "0" ] )
               then
                     if ( [ "`/usr/bin/diff ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php`" = "" ] )
                     then
                            exit
                     fi
                       /bin/cp ${HOME}/runtime/drupal_settings.php /var/www/html/sites/default/settings.php
                       /bin/chmod 600 /var/www/html/sites/default/settings.php
                       /bin/chown www-data:www-data /var/www/html/sites/default/settings.php

                       if ( [ "`/usr/bin/curl -m 2 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" = "" ] )
                       then
                               /bin/cp ${HOME}/runtime/drupal_settings.php.$$ /var/www/html/sites/default/settings.php
                       fi
               fi
        fi
fi




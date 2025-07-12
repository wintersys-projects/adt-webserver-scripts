if ( [ "`/usr/bin/find /var/www/html/configuration.php -cmin -1`" != "" ] )
then
        if ( [ "`/usr/bin/curl -m 2 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" != "" ] )
        then
                if ( [ -f ${HOME}/runtime/joomla_configuration.php ] )
                then
                        /bin/mv ${HOME}/runtime/joomla_configuration.php ${HOME}/runtime/joomla_configuration.php.$$
                fi

                /bin/cp /var/www/html/configuration.php ${HOME}/runtime/joomla_configuration.php
                /usr/bin/php -ln ${HOME}/runtime/joomla_configuration.php
                if ( [ "$?" = "0" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/joomla_configuration.php joomla_configuration.php "no"
                fi
        fi
fi

/bin/sleep 20

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh joomla_configuration.php`" -lt "130" ] && [ "`/usr/bin/find /var/www/html/configuration.php -cmin -1`" = "" ] )
then
       if ( [ -f ${HOME}/runtime/joomla_configuration.php ] )
       then
        /bin/mv ${HOME}/runtime/joomla_configuration.php ${HOME}/runtime/joomla_configuration.php.$$
       fi
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime/joomla_configuration.php
        if ( [ -f ${HOME}/runtime/joomla_configuration.php ] )
        then
                /usr/bin/php -ln ${HOME}/runtime/joomla_configuration.php
                if ( [ "$?" = "0" ] )
                then
                        if ( [ "`/usr/bin/diff ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php`" = "" ] )
                        then
                                exit
                        fi
                        /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
                        /bin/chmod 600 /var/www/html/configuration.php
                        /bin/chown www-data:www-data /var/www/html/configuration.php

                        if ( [ "`/usr/bin/curl -m 2 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" = "" ] )
                        then
                                /bin/cp ${HOME}/runtime/joomla_configuration.php.$$ /var/www/html/configuration.php
                                exit
                        fi
                fi
        else
                ${HOME}/providerscripts/email/SendEmail.sh "UNABLE TO OBTAIN APPLICATION CONFIGURATION FROM DATASTORE" "The joomla configuration file could not be obtained from the config datastore" "ERROR"
        fi
fi


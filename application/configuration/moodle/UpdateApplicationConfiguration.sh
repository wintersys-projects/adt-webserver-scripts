if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh moodle_config.php`" -lt "130" ] && [ "`/usr/bin/find /var/www/html/config.php -cmin -1`" = "" ] )
then
       if ( [ -f ${HOME}/runtime/moodle_config.php ] )
       then
        /bin/mv ${HOME}/runtime/moodle_config.php ${HOME}/runtime/moodle_config.php.$$
       fi
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh moodle_config.php ${HOME}/runtime/moodle_config.php
        /usr/bin/php -ln ${HOME}/runtime/moodle_config.php
        if ( [ "$?" = "0" ] )
        then
                /bin/cp ${HOME}/runtime/moodle_config.php /var/www/html/config.php
                /bin/chmod 600 /var/www/html/config.php
                /bin/chown www-data:www-data /var/www/html/config.php

                if ( [ "`/usr/bin/curl -m 2 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" = "" ] )
                then
                        /bin/cp ${HOME}/runtime/moodle_config.php.$$ /var/www/html/config.php
                fi
        fi
fi


if ( [ "`/usr/bin/find /var/www/html/config.php -cmin -1`" != "" ] )
then
        if ( [ "`/usr/bin/curl -m 2 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" != "" ] )
        then
                if ( [ -f ${HOME}/runtime/moodle_config.php ] )
                then
                        /bin/mv ${HOME}/runtime/moodle_config.php ${HOME}/runtime/moodle_config.php.$$
                fi

                /bin/cp /var/www/html/configuration.php ${HOME}/runtime/moodle_config.php
                /usr/bin/php -ln ${HOME}/runtime/moodle_config.php
                if ( [ "$?" = "0" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/moodle_config.php moodle_config.php "no"
                fi
        fi
fi

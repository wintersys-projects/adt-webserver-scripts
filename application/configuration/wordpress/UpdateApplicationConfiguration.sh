if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh wordpress_config.php`" -lt "130" ] && [ "`/usr/bin/find /var/www/html/wp-config.php -cmin -1`" = "" ] )
then
       if ( [ -f ${HOME}/runtime/wordpress_config.php ] )
       then
        /bin/mv ${HOME}/runtime/wordpress_config.php ${HOME}/runtime/wordpress_config.php.$$
       fi
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh wordpress_config.php ${HOME}/runtime/wordpress_config.php
        /usr/bin/php -ln ${HOME}/runtime/wordpress_config.php
        if ( [ "$?" = "0" ] )
        then
                /bin/cp ${HOME}/runtime/wordpress_config.php /var/www/html/wp-config.php
                /bin/chmod 600 /var/www/html/wp-config.php
                /bin/chown www-data:www-data /var/www/html/wp-config.php

                if ( [ "`/usr/bin/curl -m 2 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" = "" ] )
                then
                        /bin/cp ${HOME}/runtime/wordpress_config.php.$$ /var/www/html/wp-config.php
                fi
        fi
fi


if ( [ "`/usr/bin/find /var/www/html/configuration.php -cmin -1`" != "" ] )
then
        if ( [ "`/usr/bin/curl -m 2 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" != "" ] )
        then
                if ( [ -f ${HOME}/runtime/wordpress_config.php ] )
                then
                        /bin/mv ${HOME}/runtime/wordpress_config.php ${HOME}/runtime/wordpress_config.php.$$
                fi

                /bin/cp /var/www/html/wp-config.php ${HOME}/runtime/wordpress_config.php
                /usr/bin/php -ln ${HOME}/runtime/wordpress_config.php
                if ( [ "$?" = "0" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/wordpress_config.php wordpress_config.php "no"
                fi
        fi
fi




if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ "`/bin/grep "^INTERACTIVE_APPLICATION_INSTALL" ${HOME}/runtime/application.dat | /bin/sed 's/INTERACTIVE_APPLICATION_INSTALL://g' | /bin/sed 's/:/ /g'`" = "yes" ] )
then
        exit
fi

if ( [ -f /var/www/html/wp-config.php ] )
then
        /bin/rm /var/www/html/wp-config.php
fi

if ( [ -f /var/www/html/wp-config-sample.php ] )
then
        /bin/cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php.default
fi

if ( [ -f ${HOME}/runtime/application.dat ] )
then
        # We need our database prefix because that will be what is used in the database dump
        while ( [ ! -f /var/www/html/dbp.dat ] || [ "`/bin/cat  ${HOME}/runtime/wp-config.php`" = "" ] )
        do
                dbprefix="`/bin/grep "dbprefix"  ${HOME}/runtime/wp-config.php | /usr/bin/awk -F"'" '{print $2}'`"

                if ( [ "${dbprefix}" = "wp_" ] )
                then
                        dbprefix="`/usr/bin/tr -dc a-z0-9 </dev/urandom | /usr/bin/head -c 5; /bin/echo`_"
                fi
                /bin/echo ${dbprefix} > /var/www/html/dbp.dat
                /bin/chown www-data:www-data /var/www/html/dbp.dat
                /bin/chmod 600 /var/www/html/dbp.dat
        done

        dbprefix="`/bin/cat /var/www/html/dbp.dat`"
        salt="`/usr/bin/curl https://api.wordpress.org/secret-key/1.1/salt`"


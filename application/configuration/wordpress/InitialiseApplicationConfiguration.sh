


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

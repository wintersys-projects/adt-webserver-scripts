


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

/bin/cp /var/www/html/wp-config.php.default ${HOME}/runtime/wp-config.php

if ( [ -f ${HOME}/runtime/application.dat ] )
then
        # We need our database prefix because that will be what is used in the database dump
        while ( [ ! -f /var/www/html/dbp.dat ] || [ "`/bin/cat  ${HOME}/runtime/wp-config.php`" = "" ] )
        do
                table_prefix="`/bin/grep "table_prefix"  ${HOME}/runtime/wp-config.php | /usr/bin/awk -F"'" '{print $2}'`"

                if ( [ "${table_prefix}" = "wp_" ] )
                then
                        table_prefix="`/usr/bin/tr -dc a-z0-9 </dev/urandom | /usr/bin/head -c 5; /bin/echo`_"
                fi
                /bin/echo ${table_prefix} > /var/www/html/dbp.dat
                /bin/chown www-data:www-data /var/www/html/dbp.dat
                /bin/chmod 600 /var/www/html/dbp.dat
        done

        table_prefix="`/bin/cat /var/www/html/dbp.dat`"
        salt="`/usr/bin/curl https://api.wordpress.org/secret-key/1.1/salt`"

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
        then
                HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
        else
                HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
        fi

        DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

        if ( [ ! -d ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing ] )
        then
                /bin/mkdir -p ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing
        fi

        if ( [ -f ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing/exclusion_list.dat ] )
        then
                /bin/rm ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing/exclusion_list.dat
        fi
        
        for directory in `/bin/grep "^DIRECTORIES_TO_CREATE" ${HOME}/runtime/application.dat | /bin/sed 's/DIRECTORIES_TO_CREATE://g' | /bin/sed 's/:/ /g'`
        do
                if ( [ ! -d /var/www/html/${directory} ] )
                then
                        /bin/mkdir -p /var/www/html/${directory}
                fi
                /bin/chmod 755 /var/www/html/${directory}
                /bin/chown www-data:www-data /var/www/html/${directory}
                /bin/echo "/var/www/html/${directory}" >> ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing/exclusion_list.dat
        done

        for setting in `/bin/grep "^INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
        do
                label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
                value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"

                if ( [ "${label}" = "DB_HOST" ] )
                then
                        /bin/sed -i "s%\$DB_HOST =.*$%\$DB_HOST = '"${HOST}:${DB_PORT}"';%" ${HOME}/runtime/wp-config.php
                elif ( [ "${label}" = "salt" ] ) 
                then
                        /bin/sed -i -e '/AUTH/,/NONCE/s/.*/SALT_PLACEHOLDER/' -e "0,/SALT_PLACEHOLDER/s//${salt}/" -e "s/SALT_PLACEHOLDER//g" ${HOME}/runtime/wp-config.php 
                elif ( [ "${label}" = "table_prefix" ] )
                then
                        /bin/sed -i "s%\$${label} =.*$%\$${label} = '"${table_prefix}"';%" ${HOME}/runtime/wp-config.php
                else
                        /bin/sed -i "s%\$${label} =.*$%\$${label} = ${value};%" ${HOME}/runtime/wp-config.php
                fi
        done

        if ( [ ! -f /var/www/html/dbp.dat ] )
        then
                ${HOME}/providerscripts/email/SendEmail.sh "DB PREFIX FILE ABSENT" "Failed to access db prefix file" "ERROR"
                exit
        fi
fi


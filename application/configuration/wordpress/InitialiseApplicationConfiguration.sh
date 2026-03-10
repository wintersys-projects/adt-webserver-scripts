#set -x

if ( [ -f /var/www/html/wp-config.php ] )
then
        /bin/rm /var/www/html/wp-config.php
fi

if ( [ -f /var/www/html/wp-config-sample.php ] )
then
        /bin/cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php.default
        /bin/chown www-data:www-data /var/www/html/wp-config.php.default
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
        
        for directory in `/bin/grep "^DIRECTORIES_TO_CREATE:" ${HOME}/runtime/application.dat | /bin/sed 's/DIRECTORIES_TO_CREATE://g' | /bin/sed 's/:/ /g'`
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
                         /bin/sed -i "s/^define.*DB_HOST.*$/define ( 'DB_HOST','"${HOST}:${DB_PORT}"');/" ${HOME}/runtime/wp-config.php                
                elif ( [ "${label}" = "salt" ] ) 
                then
                        /usr/bin/curl "https://api.wordpress.org/secret-key/1.1/salt/" -o salts
                        /usr/bin/csplit ${HOME}/runtime/wp-config.php '/AUTH_KEY/' '/NONCE_SALT/+1'
                        /bin/cat xx00 salts xx02 > ${HOME}/runtime/wp-config.php
                        /bin/rm salts xx00 xx01 xx02                
                elif ( [ "${label}" = "table_prefix" ] )
                then
                        /bin/sed -i "s/\$table_prefix.*$/\$table_prefix ='${table_prefix}';/" ${HOME}/runtime/wp-config.php                
                else
                        if ( [ "`/bin/grep ${label} ${HOME}/runtime/wp-config.php`" != "" ] )
                        then
                                /bin/sed -i "s/define.*${label}.*$/define( '${label}' , '"${value}"');/" ${HOME}/runtime/wp-config.php
                        else
                                /bin/sed -i "/^define.*WP_DEBUG/a\define( '${label}' , '"${value}"');" ${HOME}/runtime/wp-config.php
                        fi
                fi
        done

        if ( [ ! -f /var/www/html/dbp.dat ] )
        then
                ${HOME}/providerscripts/email/SendEmail.sh "DB PREFIX FILE ABSENT" "Failed to access db prefix file" "ERROR"
                exit
        fi
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
        #This is how we tell ourselves this is a wordpress application
        /bin/echo "WORDPRESS" > /var/www/html/dba.dat
        /bin/chown www-data:www-data /var/www/html/dba.dat
        
        if ( [ -f ${HOME}/runtime/overridehtaccess/htaccess.conf ] )
        then
                /bin/cp ${HOME}/runtime/overridehtaccess/htaccess.conf /var/www/html/.htaccess 
                /bin/chmod 444 /var/www/html/.htaccess
                /bin/chown www-data:www-data /var/www/html/.htaccess
        fi

        #For ease of use we tell ourselves what database engine this webroot is associated with
        if ( [ ! -f /var/www/html/dbe.dat ] || [ "`/bin/cat /var/www/html/dbe.dat`" = "" ] )
        then
                if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
                then
                        /bin/echo "For your information this application requires Maria DB as its database" > /var/www/html/dbe.dat
                fi

                if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
                then
                        /bin/echo "For your information this application requires MySQL as its database" > /var/www/html/dbe.dat
                fi

                if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
                then
                        /bin/echo "For your information this application requires Postgres as its database" > /var/www/html/dbe.dat
                fi

                if ( [ -f /var/www/html/dbe.dat ] )
                then
                        /bin/chown www-data:www-data /var/www/html/dbe.dat
                        /bin/chmod 600 /var/www/html/dbe.dat
                fi
        fi  
fi

APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
if ( [ "`/bin/cat /var/www/html/dba.dat`" != "`/bin/echo ${APPLICATION} | /bin/tr '[:lower:]' '[:upper:]'`" ] )
then 
        ${HOME}/providerscripts/email/SendEmail.sh "APPLICATION TYPE MISMATCH" "Your template thinks it is a different application type to your webroot" "ERROR"
fi

if ( [ -f ${HOME}/runtime/wp-config.php ] )
then
        /bin/chmod 600 ${HOME}/runtime/wp-config.php
        /bin/chown www-data:www-data ${HOME}/runtime/wp-config.php
        /usr/bin/php -ln ${HOME}/runtime/wp-config.php

        if ( [ "$?" = "0" ] )
        then
                /bin/sed -i "s/\r//g" ${HOME}/runtime/wp-config.php
                /bin/mv ${HOME}/runtime/wp-config.php /var/www/html/wp-config.php
                /bin/chmod 600 /var/www/html/wp-config.php
                /bin/chown www-data:www-data /var/www/html/wp-config.php
                /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
        fi
fi

if ( [ ! -f  ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy wordpress configuration file to the live location during application initiation" "ERROR"
fi


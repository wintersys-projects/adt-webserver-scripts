#set -x

#if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
#then
#       exit
#fi

if ( [ -f /var/www/html/configuration.php ] )
then
        /bin/rm /var/www/html/configuration.php
fi

if ( [ -f /var/www/html/installation/configuration.php-dist ] )
then
        /bin/cp /var/www/html/installation/configuration.php-dist /var/www/html/configuration.php.default
fi

/bin/cp /var/www/html/configuration.php.default ${HOME}/runtime/configuration.php

if ( [ -f ${HOME}/runtime/application.dat ] )
then
        # We nneed our database prefix because that will be what is used in the database dump
        while ( [ ! -f /var/www/html/dbp.dat ] || [ "`/bin/cat  ${HOME}/runtime/configuration.php`" = "" ] )
        do
                dbprefix="`/bin/grep "dbprefix"  ${HOME}/runtime/configuration.php | /usr/bin/awk -F"'" '{print $2}'`"

                if ( [ "${dbprefix}" = "jos_" ] )
                then
                        dbprefix="`/usr/bin/tr -dc A-Za-z0-9 </dev/urandom | /usr/bin/head -c 5; /bin/echo`_"
                fi
                /bin/echo ${dbprefix} > /var/www/html/dbp.dat
                /bin/chown www-data:www-data /var/www/html/dbp.dat
                /bin/chmod 600 /var/www/html/dbp.dat
        done

        dbprefix="`/bin/cat /var/www/html/dbp.dat`"
        secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
        then
                HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
        else
                HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
        fi

        DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

        for directory in `/bin/grep "^DIRECTORIES_TO_CREATE" ${HOME}/runtime/application.dat | /bin/sed 's/DIRECTORIES_TO_CREATE://g' | /bin/sed 's/:/ /g'`
        do
                if ( [ ! -d /var/www/html/${directory} ] )
                then
                        /bin/mkdir -p /var/www/html/${directory}
                fi
                /bin/chmod 755 /var/www/html/${directory}
                /bin/chown www-data:www-data /var/www/html/${directory}
        done

        for setting in `/bin/grep "^INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
        do
                label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
                value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"

                if ( [ "${label}" = "host" ] )
                then
                        /bin/sed -i "s%\$host =.*$%\$host = '"${HOST}:${DB_PORT}"';%" ${HOME}/runtime/configuration.php
                elif ( [ "${label}" = "secret" ] ) 
                then
                        /bin/sed -i "s%\$${label} =.*$%\$${label} = '"${secret}"';%" ${HOME}/runtime/configuration.php
                elif ( [ "${label}" = "dbprefix" ] )
                then
                        /bin/sed -i "s%\$${label} =.*$%\$${label} = '"${dbprefix}"';%" ${HOME}/runtime/configuration.php
                else
                        /bin/sed -i "s%\$${label} =.*$%\$${label} = ${value};%" ${HOME}/runtime/configuration.php
                fi
        done

        if ( [ ! -f /var/www/html/dbp.dat ] )
        then
                ${HOME}/providerscripts/email/SendEmail.sh "DB PREFIX FILE ABSENT" "Failed to access db prefix file" "ERROR"
                exit
        fi
fi


/bin/cat /var/www/html/installation/sql/mysql/base.sql | /bin/sed "s/#__/${dbprefix}/g" > /var/www/html/installation/sql/mysql/base_with_dbprefix.sql
/bin/cat /var/www/html/installation/sql/mysql/extensions.sql | /bin/sed "s/#__/${dbprefix}/g" > /var/www/html/installation/sql/mysql/extensions_with_dbprefix.sql
/bin/cat /var/www/html/installation/sql/mysql/supports.sql | /bin/sed "s/#__/${dbprefix}/g" > /var/www/html/installation/sql/mysql/supports_with_dbprefix.sql

${HOME}/utilities/remote/ConnectToRemoteMySQL.sh < /var/www/html/installation/sql/mysql/base_with_dbprefix.sql 
${HOME}/utilities/remote/ConnectToRemoteMySQL.sh < /var/www/html/installation/sql/mysql/extensions_with_dbprefix.sql 
${HOME}/utilities/remote/ConnectToRemoteMySQL.sh < /var/www/html/installation/sql/mysql/supports_with_dbprefix.sql 


username="`/bin/grep "^APPLICATION_USERNAME" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_USERNAME://g' | /bin/sed 's/:/ /g'`"
password="`/bin/grep "^APPLICATION_PASSWORD" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_PASSWORD://g' | /bin/sed 's/:/ /g' | /usr/bin/md5sum | /usr/bin/awk '{print $1}'`"
descriptive_name="`/bin/grep "^APPLICATION_DESCRIPTIVE_USERNAME" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_DESCRIPTIVE_USERNAME://g' | /bin/sed 's/:/ /g'`"

/bin/echo "INSERT INTO `${dbprefix}users` (`name`, `username`, `password`, `params`, `registerDate`, `lastvisitDate`, `lastResetTime`) VALUES ('"${descriptive_name}"', '"${username}"','"${password}"', '', NOW(), NOW(), NOW());" > /var/www/html/installation/sql/mysql/user_with_dbprefix.sql 
/bin/echo "INSERT INTO `${dbprefix}user_usergroup_map` (`user_id`,`group_id`) VALUES (LAST_INSERT_ID(),'8');" >> /var/www/html/installation/sql/mysql/user_with_dbprefix.sql 

${HOME}/utilities/remote/ConnectToRemoteMySQL.sh < /var/www/html/installation/sql/mysql/user_with_dbprefix.sql  

if ( [ -d /var/www/html/installation ] )
then
        /bin/rm -r /var/www/html/installation
fi

if ( [ -f ${HOME}/runtime/configuration.php ] )
then
        /bin/chmod 600 ${HOME}/runtime/configuration.php
        /bin/chown www-data:www-data ${HOME}/runtime/configuration.php
        /usr/bin/php -ln ${HOME}/runtime/configuration.php
        if ( [ "$?" = "0" ] )
        then
                /bin/mv ${HOME}/runtime/configuration.php /var/www/html/configuration.php
                /bin/chmod 600 /var/www/html/configuration.php
                /bin/chown www-data:www-data /var/www/html/configuration.php
                /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
        fi
fi

if ( [ ! -f  ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"
fi

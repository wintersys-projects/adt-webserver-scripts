#set -x

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ "`/bin/grep "^INTERACTIVE_APPLICATION_INSTALL" ${HOME}/runtime/application.dat | /bin/sed 's/INTERACTIVE_APPLICATION_INSTALL://g' | /bin/sed 's/:/ /g'`" = "yes" ] )
then
        exit
fi

if ( [ -f /var/www/html/configuration.php ] )
then
        /bin/rm /var/www/html/configuration.php
fi

if ( [ -f /var/www/html/installation/configuration.php-dist ] )
then
        /bin/cp /var/www/html/installation/configuration.php-dist /var/www/html/configuration.php.default
        /bin/chown www-data:www-data /var/www/html/configuration.php.default
fi

/bin/cp /var/www/html/configuration.php.default ${HOME}/runtime/configuration.php

while ( [ ! -f /var/www/html/dbp.dat ] || [ "`/bin/cat  ${HOME}/runtime/configuration.php`" = "" ] )
do
        dbprefix="`/bin/grep "dbprefix"  ${HOME}/runtime/configuration.php | /usr/bin/awk -F"'" '{print $2}'`"

        if ( [ "${dbprefix}" = "jos_" ] )
        then
                dbprefix="adt`/usr/bin/tr -dc a-z0-9 </dev/urandom | /usr/bin/head -c 5; /bin/echo`_"
        fi
        /bin/echo ${dbprefix} > /var/www/html/dbp.dat
        /bin/chown www-data:www-data /var/www/html/dbp.dat
        /bin/chmod 600 /var/www/html/dbp.dat
done

if ( [ ! -f /var/www/html/dbp.dat ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "DB PREFIX FILE ABSENT" "Failed to access db prefix file" "ERROR"
        exit
else
        # We need our database prefix because that will be what is used in the database dump
        dbprefix="`/bin/cat /var/www/html/dbp.dat`"
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
        HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
        HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
fi
DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

if ( [ -f ${HOME}/runtime/application.dat ] )
then
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

        for directory in `/bin/grep "^DIRECTORIES_TO_CREATE_ABSOLUTE:" ${HOME}/runtime/application.dat | /bin/sed 's/DIRECTORIES_TO_CREATE_ABSOLUTE://g' | /bin/sed 's/:/ /g'`
        do
                if ( [ ! -d ${directory} ] )
                then
                        /bin/mkdir -p ${directory}
                fi
                /bin/chmod -R 755 ${directory}
                /bin/chown -R www-data:www-data ${directory}
        done

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" != "1" ] )
        then
                secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
                for setting in `/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^MANDATORY_INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
                do
                        label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
                        value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"

                        if ( [ "${label}" != "" ] && [ "${value}" != "" ] )
                        then
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
                        fi
                done

                if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
                then
                        /bin/sed -i "s%\$dbtype =.*$%\$dbtype = '"mysqli"';%" ${HOME}/runtime/configuration.php
                elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
                then
                        /bin/sed -i "s%\$dbtype =.*$%\$dbtype = '"mysqli"';%" ${HOME}/runtime/configuration.php
                elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ])
                then
                        /bin/sed -i "s%\$dbtype =.*$%\$dbtype = '"pgsql"';%" ${HOME}/runtime/configuration.php
                fi
                        
                APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
                if ( [ "`/bin/cat /var/www/html/dba.dat`" != "`/bin/echo ${APPLICATION} | /bin/tr '[:lower:]' '[:upper:]'`" ] )
                then 
                        ${HOME}/providerscripts/email/SendEmail.sh "APPLICATION TYPE MISMATCH" "Your template thinks it is a different application type to your webroot" "ERROR"
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
        else
                #This is how we tell ourselves this is a joomla application
                /bin/echo "JOOMLA" > /var/www/html/dba.dat
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
        
                cd /var/www/html
                website_name="`/bin/grep "^WEBSITE_NAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
                website_username="`/bin/grep "^WEBSITE_USERNAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
                website_password="`/bin/grep "^WEBSITE_PASSWORD:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
                website_user_description="`/bin/grep "^WEBSITE_USER_DESCRIPTION:" ${HOME}/runtime/application.dat |  /usr/bin/awk -F':' '{print $NF}'`"
                db_username="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:user=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"
                db_password="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:password=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"
                db_name="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:db=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"
                db_type="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:type=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"
                /usr/bin/php installation/joomla.php install --site-name="${website_name}" --admin-user="${website_user_description}" --admin-email="changeme@adt-installation-bootstrap.uk" --admin-username="${website_username}" --admin-password="${website_password}"  --db-type=${db_type} --db-host=${HOST}:${DB_PORT}  --db-user=${db_username} --db-pass=${db_password} --db-name=${db_name}  --db-prefix=${dbprefix} --no-interaction  
                /bin/chown -R www-data:www-data /var/www/html

                for setting in `/bin/grep "^INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
                do
                        label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
                        value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"
                        if ( [ "${label}" != "" ] && [ "${value}" != "" ] )
                        then
                                /bin/sed -i "s%\$${label} =.*$%\$${label} = ${value};%" /var/www/html/configuration.php
                        fi
                done
                
                /usr/bin/php -ln /var/www/html/configuration.php

                if ( [ "$?" = "0" ] )
                then
                        /bin/chmod 600 /var/www/html/configuration.php
                        /bin/chown www-data:www-data /var/www/html/configuration.php
                        /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
                fi
        fi
fi

if ( [ ! -f  ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"
fi

set -x

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

if ( [ -f ${HOME}/runtime/application.dat ] )
then
        # We need our database prefix because that will be what is used in the database dump
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
        fi

        dbprefix="`/bin/cat /var/www/html/dbp.dat`"
        secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"

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

        for directory in `/bin/grep "^DIRECTORIES_TO_CREATE_ABSOLUTE:" ${HOME}/runtime/application.dat | /bin/sed 's/DIRECTORIES_TO_CREATE_ABSOLUTE://g' | /bin/sed 's/:/ /g'`
        do
                if ( [ ! -d ${directory} ] )
                then
                        /bin/mkdir -p ${directory}
                fi
                /bin/chmod -R 755 ${directory}
                /bin/chown -R www-data:www-data ${directory}
        done

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] )
        then
                for setting in `/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^MANDATORY_INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
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
        
            #    if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
            #    then
            #            /bin/cat /var/www/html/installation/sql/mysql/base.sql | /bin/sed "s/#__/${dbprefix}/g" > /var/www/html/installation/sql/mysql/base_with_dbprefix.sql
            #            /bin/cat /var/www/html/installation/sql/mysql/extensions.sql | /bin/sed "s/#__/${dbprefix}/g" > /var/www/html/installation/sql/mysql/extensions_with_dbprefix.sql
            #            /bin/cat /var/www/html/installation/sql/mysql/supports.sql | /bin/sed "s/#__/${dbprefix}/g" > /var/www/html/installation/sql/mysql/supports_with_dbprefix.sql
#
 #                       ${HOME}/utilities/remote/ConnectToRemoteMySQL.sh < /var/www/html/installation/sql/mysql/base_with_dbprefix.sql 
  #                      ${HOME}/utilities/remote/ConnectToRemoteMySQL.sh < /var/www/html/installation/sql/mysql/extensions_with_dbprefix.sql 
   #                     ${HOME}/utilities/remote/ConnectToRemoteMySQL.sh < /var/www/html/installation/sql/mysql/supports_with_dbprefix.sql 
#
#
 #                       username="`/bin/grep "^APPLICATION_USERNAME" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_USERNAME://g' | /bin/sed 's/:/ /g'`"
  #                      password="`/bin/grep "^APPLICATION_PASSWORD_HASH" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_PASSWORD_HASH://g' | /bin/sed 's/:/ /g'`"
   #                     descriptive_name="`/bin/grep "^APPLICATION_DESCRIPTIVE_USERNAME" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_DESCRIPTIVE_USERNAME://g' | /bin/sed 's/:/ /g'`"
#
 #                       /bin/echo "INSERT INTO \`${dbprefix}users\` (\`name\`, \`username\`, \`password\`, \`params\`, \`registerDate\`, \`lastvisitDate\`, \`lastResetTime\`) VALUES ('"${descriptive_name}"', '"${username}"','"${password}"', '', NOW(), NOW(), NOW());" > /var/www/html/installation/sql/mysql/user_with_dbprefix.sql 
  #                      /bin/echo "INSERT INTO \`${dbprefix}user_usergroup_map\` (\`user_id\`,\`group_id\`) VALUES (LAST_INSERT_ID(),'8');" >> /var/www/html/installation/sql/mysql/user_with_dbprefix.sql 
#
 #                       ${HOME}/utilities/remote/ConnectToRemoteMySQL.sh < /var/www/html/installation/sql/mysql/user_with_dbprefix.sql  
#
 #                       extension_id="`${HOME}/utilities/remote/ConnectToRemoteMySQL.sh "select extension_id,name from ${dbprefix}extensions where name='files_joomla';" | /bin/grep 'files_joomla' | /usr/bin/awk '{print $1}'`"
  #                      version_id="`/bin/ls /var/www/html/administrator/components/com_admin/sql/updates/mysql | /usr/bin/tail -n -1`"
   #                     /bin/echo "INSERT INTO \`${dbprefix}schemas\` (\`extension_id\`, \`version_id\`) VALUES (${extension_id}, '"${version_id}"');" > /var/www/html/installation/sql/mysql/noninteractive_fudge_with_dbprefix.sql
    #                    ${HOME}/utilities/remote/ConnectToRemoteMySQL.sh < /var/www/html/installation/sql/mysql/noninteractive_fudge_with_dbprefix.sql
     #           elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
      #          then
       #                 /bin/cat /var/www/html/installation/sql/postgresql/base.sql | /bin/sed "s/#__/${dbprefix}/g" > /var/www/html/installation/sql/postgresql/base_with_dbprefix.psql
        #                /bin/cat /var/www/html/installation/sql/postgresql/extensions.sql | /bin/sed "s/#__/${dbprefix}/g" > /var/www/html/installation/sql/postgresql/extensions_with_dbprefix.psql
         #               /bin/cat /var/www/html/installation/sql/postgresql/supports.sql | /bin/sed "s/#__/${dbprefix}/g" > /var/www/html/installation/sql/postgresql/supports_with_dbprefix.psql
#
 #                       ${HOME}/utilities/remote/ConnectToRemotePostgres.sh < /var/www/html/installation/sql/postgresql/base_with_dbprefix.psql 
  #                      ${HOME}/utilities/remote/ConnectToRemotePostgres.sh < /var/www/html/installation/sql/postgresql/extensions_with_dbprefix.psql 
   #                     ${HOME}/utilities/remote/ConnectToRemotePostgres.sh < /var/www/html/installation/sql/postgresql/supports_with_dbprefix.psql 
#
 #                       username="`/bin/grep "^APPLICATION_USERNAME" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_USERNAME://g' | /bin/sed 's/:/ /g'`"
  #                      password="`/bin/grep "^APPLICATION_PASSWORD_HASH" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_PASSWORD_HASH://g' | /bin/sed 's/:/ /g'`"
   #                     descriptive_name="`/bin/grep "^APPLICATION_DESCRIPTIVE_USERNAME" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_DESCRIPTIVE_USERNAME://g' | /bin/sed 's/:/ /g'`"
#
 #                       /bin/echo 'INSERT INTO '${dbprefix}'users (name, username,  password, params, "registerDate", "lastvisitDate", "lastResetTime") VALUES ( '\'${descriptive_name}\'', '\'${username}\'', '\'${password}\'', '"''"', now(), now(), now()) RETURNING id;' > /var/www/html/installation/sql/postgresql/user_with_dbprefix.psql 
#                        returning_id="`${HOME}/utilities/remote/ConnectToRemotePostgres.sh < /var/www/html/installation/sql/postgresql/user_with_dbprefix.psql | /bin/grep -oE '[0-9]+' | /bin/sed -n '1p' | /bin/sed 's/ //g'`"
#
 #                       /bin/echo "INSERT INTO ${dbprefix}user_usergroup_map (user_id, group_id) VALUES (${returning_id},'8');" > /var/www/html/installation/sql/postgresql/user_with_dbprefix.psql 
#
 #                       ${HOME}/utilities/remote/ConnectToRemotePostgres.sh < /var/www/html/installation/sql/postgresql/user_with_dbprefix.psql
#
 #                       extension_id="`${HOME}/utilities/remote/ConnectToRemotePostgres.sh "select extension_id,name from ${dbprefix}extensions where name='files_joomla';" | /bin/grep 'files_joomla' | /usr/bin/awk '{print $1}' | /usr/bin/tail -n -1`"
  #                      version_id="`/bin/ls /var/www/html/administrator/components/com_admin/sql/updates/postgresql | /usr/bin/tail -n -1`"
   #                     /bin/echo "INSERT INTO ${dbprefix}schemas (extension_id, version_id) VALUES (${extension_id}, '"${version_id}"');" > /var/www/html/installation/sql/postgresql/noninteractive_fudge_with_dbprefix.psql
    #                    ${HOME}/utilities/remote/ConnectToRemotePostgres.sh < /var/www/html/installation/sql/postgresql/noninteractive_fudge_with_dbprefix.psql
#
 #               fi

                cd /var/www/html

                db_username="`/bin/grep "^INDIVIDUAL_SETTING:user=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`"
                db_password="`/bin/grep "^INDIVIDUAL_SETTING:password=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`"
                db_name="`/bin/grep "^INDIVIDUAL_SETTING:db=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`"
                db_type="`/bin/grep "^INDIVIDUAL_SETTING:type=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`"
                WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
                /usr/bin/php installation/joomla.php install --site-name="${WEBSITE_NAME}" --admin-user=Webmaster --admin-email=changeme@adt-installation-bootstrap.uk --admin-username=webmaster --admin-password=mnbcxz098321QQQZZZ  --db-type=${db_type} --db-host=${HOST}:${DB_PORT}  --db-user=${db_username} --db-pass=${db_password} --db-name=${db_name}  --db-prefix=${dbprefix} --no-interaction  
                /bin/chown -R www-data:www-data /var/www/html

                for setting in `/bin/grep "^INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
                do
                        label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
                        value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"
                        /bin/sed -i "s%\$${label} =.*$%\$${label} = ${value};%" /var/www/html/configuration.php
                done
                
                /usr/bin/php -ln /var/www/html/configuration.php

                if ( [ "$?" = "0" ] )
                then
                        /bin/chmod 600 /var/www/html/configuration.php
                        /bin/chown www-data:www-data /var/www/html/configuration.php
                        /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
                fi


#               if ( [ -d /var/www/html/installation ] )
 #              then
  #                     /bin/rm -r /var/www/html/installation
   #            fi
        fi
fi

if ( [ ! -f  ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"
fi

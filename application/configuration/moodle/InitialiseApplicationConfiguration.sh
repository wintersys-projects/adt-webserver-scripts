#set -x

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ "`/bin/grep "^INTERACTIVE_APPLICATION_INSTALL" ${HOME}/runtime/application.dat | /bin/sed 's/INTERACTIVE_APPLICATION_INSTALL://g' | /bin/sed 's/:/ /g'`" = "yes" ] )
then
        exit
fi

if ( [ -f /var/www/html/config.php ] )
then
        /bin/rm /var/www/html/config.php
fi

if ( [ -f /var/www/html/config-dist.php ] )
then
        /bin/cp /var/www/html/config-dist.php /var/www/html/config.php.default
        /bin/chown www-data:www-data /var/www/html/config.php.default
fi

/bin/cp /var/www/html/config.php.default ${HOME}/runtime/config.php

if ( [ -f ${HOME}/runtime/application.dat ] )
then
        # We need our database prefix because that will be what is used in the database dump
        while ( [ ! -f /var/www/html/dbp.dat ] || [ "`/bin/cat  ${HOME}/runtime/config.php`" = "" ] )
        do
                dbprefix="`/bin/grep '^$CFG->prefix' ${HOME}/runtime/config.php | /usr/bin/awk -F"'" '{print $2}'`"

                if ( [ "${dbprefix}" = "mdl_" ] )
                then
                        dbprefix="`/usr/bin/tr -dc a-z0-9 </dev/urandom | /usr/bin/head -c 5; /bin/echo`_"
                fi
                /bin/echo ${dbprefix} > /var/www/html/dbp.dat
                /bin/chown www-data:www-data /var/www/html/dbp.dat
                /bin/chmod 600 /var/www/html/dbp.dat
        done

        dbprefix="`/bin/cat /var/www/html/dbp.dat`"

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

                if ( [ "${label}" = '$CFG->dbhost' ] )
                then
                        /bin/sed -i "s%${label}.*$%${label} = '${HOST}';%" ${HOME}/runtime/config.php
                elif ( [ "${label}" = '$CFG->prefix' ] )
                then
                        /bin/sed -i "s%${label}.*$%${label} = '${dbprefix}';%" ${HOME}/runtime/config.php
                else
                        /bin/sed -i "s%${label}.*$%${label} = '${value}';%" ${HOME}/runtime/config.php
                fi
        done

        /bin/sed -i "1,/dbport/s/.*dbport.*/'dbport'    => '${DB_PORT}',/"  ${HOME}/runtime/config.php

        WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
        /bin/sed -i "s%\$CFG->wwwroot.*$%\$CFG->wwwroot = 'https://${WEBSITE_URL}';%" ${HOME}/runtime/config.php
        /bin/sed -i "s%\$CFG->dataroot.*$%\$CFG->dataroot = '/var/www/moodledata';%" ${HOME}/runtime/config.php

        if ( [ ! -f /var/www/html/dbp.dat ] )
        then
                ${HOME}/providerscripts/email/SendEmail.sh "DB PREFIX FILE ABSENT" "Failed to access db prefix file" "ERROR"
                exit
        fi
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
then
        /bin/sed -i 's/$CFG->dbtype.*$/$CFG->dbtype = "mariadb";/g' ${HOME}/runtime/config.php
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
        /bin/sed -i 's/$CFG->dbtype.*$/$CFG->dbtype = "mysqli";/g' ${HOME}/runtime/config.php
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ])
then
        /bin/sed -i 's/$CFG->dbtype.*$/$CFG->dbtype = "pgsql";/g' ${HOME}/runtime/config.php
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
        #This is how we tell ourselves this is a joomla application
        /bin/echo "MOODLE" > /var/www/html/dba.dat
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

      #  if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
      #  then
      #          :
      #  elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
      #  then
      #          :#
#
 #       fi

        /var/www/html/admin/cli/install_database.php --adminuser= --adminpass= --agree-license

fi


APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
if ( [ "`/bin/cat /var/www/html/dba.dat`" != "`/bin/echo ${APPLICATION} | /bin/tr '[:lower:]' '[:upper:]'`" ] )
then 
        ${HOME}/providerscripts/email/SendEmail.sh "APPLICATION TYPE MISMATCH" "Your template thinks it is a different application type to your webroot" "ERROR"
fi

if ( [ -f ${HOME}/runtime/config.php ] )
then
        /bin/chmod 600 ${HOME}/runtime/config.php
        /bin/chown www-data:www-data ${HOME}/runtime/config.php
        /usr/bin/php -ln ${HOME}/runtime/config.php

        if ( [ "$?" = "0" ] )
        then
                /bin/mv ${HOME}/runtime/config.php /var/www/html/config.php
                /bin/chmod 600 /var/www/html/config.php
                /bin/chown www-data:www-data /var/www/html/config.php
                /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
        fi
fi

if ( [ ! -f  ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"
fi

WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

if ( [ -f /etc/apache2/sites-available/${WEBSITE_NAME} ] )
then
        /bin/sed -i 's;/var/www/html;/var/www/html/public;' /etc/apache2/sites-available/${WEBSITE_NAME}
fi

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
        /bin/sed -i 's;/var/www/html;/var/www/html/public;' /etc/nginx/sites-available/${WEBSITE_NAME}
fi

if ( [ -f /etc/lighttpd/lighttpd.conf ] )
then
        /bin/sed -i 's;/var/www/html;/var/www/html/public;' /etc/lighttpd/lighttpd.conf
fi

${HOME}/providerscripts/webserver/RestartWebserver.sh

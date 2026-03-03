set -x

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
        exit
fi

if ( [ -f /var/www/html/configuration.php ] )
then
        /bin/rm /var/www/html/configuration.php
fi

/bin/cp /var/www/html/configuration.php.default ${HOME}/runtime/configuration.php

if ( [ -f ${HOME}/runtime/application.dat ] )
then

        dbprefix="`/bin/cat /var/www/html/dbp.dat`"
        secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
        then
                HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
        else
                HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
        fi
        
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
        
                if ( [ "${label}" = "db_port" ] )
                then
                        /bin/sed -i "s/\$${label} =.*$/\$${label} = '${HOST}:${db_port}';/" ${HOME}/runtime/configuration.php
                elif ( [ "${label}" = "secret" ] ) 
                then
                        /bin/sed -i "s/\$${label} =.*$/\$${label} = ${secret};/" ${HOME}/runtime/configuration.php
                elif ( [ "${label}" = "dbprefix" ] )
                then
                        /bin/sed -i "s/\$${label} =.*$/\$${label} = ${dbprefix};/" ${HOME}/runtime/configuration.php
                else
                        /bin/sed -i "s/\$${label} =.*$/\$${label} = ${value};/" ${HOME}/runtime/configuration.php
                fi
        done

        if ( [ ! -f /var/www/html/dbp.dat ] )
        then
                ${HOME}/providerscripts/email/SendEmail.sh "DB PREFIX FILE ABSENT" "Failed to access db prefix file" "ERROR"
                exit
        fi

  #      dbprefix="`/bin/cat /var/www/html/dbp.dat`"
  #      secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"#
#
 #       if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
  #      then
   #             HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
    #    else
     #           HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
      #  fi

     #   /bin/sed -i '/$dbprefix /c\        public $dbprefix = "'${dbprefix}'";' ${HOME}/runtime/configuration.php
     #   /bin/sed -i '/$secret /c\        public $secret = "'${secret}'";' ${HOME}/runtime/configuration.php
     #   /bin/sed -i '/$host /c\        public $host = "'${HOST}:${db_port}'";' ${HOME}/runtime/configuration.php

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

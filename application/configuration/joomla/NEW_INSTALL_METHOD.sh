
/bin/cp /var/www/html/configuration.php.default ${HOME}/runtime/configuration.php

#APPLICATION_NAME:joomla
#DIRECTORIES_TO_CREATE:logs:tmp:cache
#SOURCECODE_URL:github.com/joomla/joomla-cms/releases/download/=6.0.0/Joomla_=6.0.0-Stable-Full_Package.zip
#APPLICATION_CREDENTIALS:username="ujfwj5kgiu":password="pqzsdwv9op":database="ndxhton7yn":db_port="2035":host="self-managed":type="mysqli"
#INTERACTIVE_APPLICATION_INSTALL="no"

if ( [ -f ${HOME}/runtime/application.dat ] )
then
        for directory in `/bin/grep "^DIRECTORIES_TO_CREATE" ${HOME}/runtime/application.dat | /bin/sed 's/DIRECTORIES_TO_CREATE://g' | /bin/sed 's/:/ /g'`
        do
                if ( [ ! -d /var/www/html/${directory} ] )
                then
                        /bin/mkdir -p /var/www/html/${directory}
                fi
                /bin/chmod 755 /var/www/html/${directory}
                /bin/chown www-data:www-data /var/www/html/${directory}
        done


        for setting in `/bin/grep "^APPLICATION_CREDENTIALS" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_CREDENTIALS://g' | /bin/sed 's/:/ /g'`
        do
                if ( [ "`/bin/echo ${setting} | /bin/grep "^username="`" != "" ] )
                then
                        username="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
                fi

                if ( [ "`/bin/echo ${setting} | /bin/grep "^password="`" != "" ] )
                then
                        password="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
                fi

                if ( [ "`/bin/echo ${setting} | /bin/grep "^database="`" != "" ] )
                then
                        database="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
                fi

                if ( [ "`/bin/echo ${setting} | /bin/grep "^db_port="`" != "" ] )
                then
                        db_port="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
                fi

                if ( [ "`/bin/echo ${setting} | /bin/grep "^type="`" != "" ] )
                then
                        type="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
                fi

                if ( [ ! -f /var/www/html/dbp.dat ] )
                then
                        /bin/echo "error"
                fi

                dbprefix="`/bin/cat /var/www/html/dbp.dat`"
                secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
        done

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
        then
                HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
        else
                HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
        fi

        /bin/sed -i '/$dbprefix /c\        public $dbprefix = "'${dbprefix}'";' ${HOME}/runtime/configuration.php
        /bin/sed -i '/$secret /c\        public $secret = "'${secret}'";' ${HOME}/runtime/configuration.php
        /bin/sed -i '/$user/c\       public $user = "'${username}'";' ${HOME}/runtime/configuration.php
        /bin/sed -i '/$password/c\   public $password = "'${password}'";' ${HOME}/runtime/configuration.php
        /bin/sed -i '/$db /c\        public $db = "'${database}'";' ${HOME}/runtime/configuration.php
        /bin/sed -i '/$dbtype /c\        public $dbtype = "'${type}'";' ${HOME}/runtime/configuration.php
        /bin/sed -i '/$host /c\        public $host = "'${HOST}:${db_port}'";' ${HOME}/runtime/configuration.php
        /bin/cp ${HOME}/runtime/configuration.php /var/www/html
        /bin/chmod 600 /var/www/html/configuration.php
        /bin/chown www-data:www-data /var/www/html/configuration.php
fi

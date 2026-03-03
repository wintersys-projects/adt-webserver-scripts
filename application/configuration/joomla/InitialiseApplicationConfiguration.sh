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
        for directory in `/bin/grep "^DIRECTORIES_TO_CREATE" ${HOME}/runtime/application.dat | /bin/sed 's/DIRECTORIES_TO_CREATE://g' | /bin/sed 's/:/ /g'`
        do
                if ( [ ! -d /var/www/html/${directory} ] )
                then
                        /bin/mkdir -p /var/www/html/${directory}
                fi
                /bin/chmod 755 /var/www/html/${directory}
                /bin/chown www-data:www-data /var/www/html/${directory}
        done


#        for setting in `/bin/grep "^APPLICATION_CREDENTIALS" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_CREDENTIALS://g' | /bin/sed 's/:/ /g'`
#       do
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^username="`" != "" ] )
#               then
#                      username="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#             fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^password="`" != "" ] )
#              then
#                     password="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^database="`" != "" ] )
#              then
#                     database="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^db_port="`" != "" ] )
#              then
#                     db_port="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^type="`" != "" ] )
#              then
#                     type="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ ! -f /var/www/html/dbp.dat ] )
#              then
#                     /bin/echo "error"
#            fi
#
#               dbprefix="`/bin/cat /var/www/html/dbp.dat`"
#              secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
#     done
#
#       if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
#      then
#             HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
#    else
#           HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
#  fi
#
#       /bin/sed -i '/$dbprefix /c\        public $dbprefix = "'${dbprefix}'";' ${HOME}/runtime/configuration.php
#      /bin/sed -i '/$secret /c\        public $secret = "'${secret}'";' ${HOME}/runtime/configuration.php
#     /bin/sed -i '/$user/c\       public $user = "'${username}'";' ${HOME}/runtime/configuration.php
#    /bin/sed -i '/$password/c\   public $password = "'${password}'";' ${HOME}/runtime/configuration.php
#   /bin/sed -i '/$db /c\        public $db = "'${database}'";' ${HOME}/runtime/configuration.php
#  /bin/sed -i '/$dbtype /c\        public $dbtype = "'${type}'";' ${HOME}/runtime/configuration.php
# /bin/sed -i '/$host /c\        public $host = "'${HOST}:${db_port}'";' ${HOME}/runtime/configuration.php
#
#       for setting in `/bin/grep "^MAILER_SETTINGS" ${HOME}/runtime/application.dat | /bin/sed 's/MAILER_SETTINGS://g' | /bin/sed 's/:/ /g'`
#      do
#             if ( [ "`/bin/echo ${setting} | /bin/grep "^mailer="`" != "" ] )
#            then
#                   mailer="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#          fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^from_email="`" != "" ] )
#              then
#                     from_email="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^reply_to="`" != "" ] )
#              then
#                     reply_to="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^from_name="`" != "" ] )
#              then
#                     from_name="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^reply_to_name="`" != "" ] )
#              then
#                     reply_to_name="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^smtp_auth="`" != "" ] )
#              then
#                     smtp_auth="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^smtp_username="`" != "" ] )
#              then
#                     smtp_username="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^smtp_password="`" != "" ] )
#              then
#                     smtp_password="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^smtp_secure="`" != "" ] )
#              then
#                     smtp_secure="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^smtp_port="`" != "" ] )
#               then
#                      smtp_port="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#             fi
#
#               if ( [ "`/bin/echo ${setting} | /bin/grep "^smtp_host="`" != "" ] )
#              then
#                     smtp_host="`/bin/echo ${setting} | /usr/bin/awk -F'"' '{print $2}'`"
#            fi
#   done
#
#       /bin/sed -i '/$mailer /c\        public $mailer = "'${mailer}'";' ${HOME}/runtime/configuration.php
#      /bin/sed -i '/$mailfrom /c\        public $mailfrom = "'${from_email}'";' ${HOME}/runtime/configuration.php
#     /bin/sed -i '/$replyto /c\        public $replyto = "'${reply_to}'";' ${HOME}/runtime/configuration.php
#    /bin/sed -i '/$fromname /c\        public $fromname = "'${from_name}' Webmaster";' ${HOME}/runtime/configuration.php
#   /bin/sed -i '/$replytoname /c\        public $replytoname = "'${reply_to_name}' Webmaster";' ${HOME}/runtime/configuration.php
#  /bin/sed -i '/$smtpauth /c\        public $smtpauth = "'${smtp_auth}'";' ${HOME}/runtime/configuration.php
# /bin/sed -i '/$smtpuser /c\        public $smtpuser = "'${smtp_username}'";' ${HOME}/runtime/configuration.php
#/bin/sed -i '/$smtppass /c\        public $smtppass = "'${smtp_password}'";' ${HOME}/runtime/configuration.php
#        /bin/sed -i '/$smtpsecure /c\        public $smtpsecure = "'${smtp_secure}'";' ${HOME}/runtime/configuration.php
#       /bin/sed -i '/$smtpport /c\        public $smtpport = "'${smtp_port}'";' ${HOME}/runtime/configuration.php
#      /bin/sed -i '/$smtphost /c\        public $smtphost = "'${smtp_host}'";' ${HOME}/runtime/configuration.php
#
####ADDED

for setting in `/bin/grep "^INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
do
        label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
        value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"
        if ( [ "${label}" = "db_port" ] )
        then
                db_port="${value}"
        else
                /bin/sed -i "s/\$${label} =.*$/\$${label} = ${value};/" ${HOME}/runtime/configuration.php
        fi
done

if ( [ ! -f /var/www/html/dbp.dat ] )
then
        /bin/echo "error"
fi

dbprefix="`/bin/cat /var/www/html/dbp.dat`"
secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
        HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
        HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
fi

/bin/sed -i '/$dbprefix /c\        public $dbprefix = "'${dbprefix}'";' ${HOME}/runtime/configuration.php
/bin/sed -i '/$secret /c\        public $secret = "'${secret}'";' ${HOME}/runtime/configuration.php
/bin/sed -i '/$host /c\        public $host = "'${HOST}:${db_port}'";' ${HOME}/runtime/configuration.php

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

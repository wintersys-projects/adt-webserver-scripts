#!/bin/sh
###########################################################################################################
# Description: Initialise Application Configuration - called during machine build process
# Author : Peter Winter
# Date: 17/05/2017
######################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
######################################################################################################
#set -x

if ( [ -f /var/www/html/sites/default/settings.php ] )
then
        /bin/rm /var/www/html/sites/default/settings.php
fi

if ( [ -f /var/www/html/sites/default/default.settings.php ] )
then
        /bin/cp /var/www/html/sites/default/default.settings.php /var/www/html/settings.php.default
fi

/bin/cp /var/www/html/settings.php.default ${HOME}/runtime/settings.php

if ( [ -f ${HOME}/runtime/application.dat ] )
then
        # We need our database prefix because that will be what is used in the database dump
        while ( [ ! -f /var/www/html/dbp.dat ] )
        do
                db_prefix="`/usr/bin/tr -dc a-z0-9 </dev/urandom | /usr/bin/head -c 5; /bin/echo`_"
                /bin/echo ${db_prefix} > /var/www/html/dbp.dat
                /bin/chown www-data:www-data /var/www/html/dbp.dat
                /bin/chmod 600 /var/www/html/dbp.dat
        done

        db_prefix="`/bin/cat /var/www/html/dbp.dat`"

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
                /bin/chmod -R 755 /var/www/html/${directory}
                /bin/chown -R www-data:www-data /var/www/html/${directory}
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

        /bin/echo "  \$databases['default']['default'] = [
        'database' => 'XXXXdatabaseXXXX',
        'username' => 'XXXXusernameXXXX',
        'password' => 'XXXXpasswordXXXX',
        'host' => 'XXXXhostXXXX',
        'port' => 'XXXXportXXXX',
        'driver' => 'XXXXdriverXXXX',
        'prefix' => 'XXXXprefixXXXX',
        'collation' => 'utf8mb4_general_ci',
        ];" > ${HOME}/runtime/application_db.dat

        for setting in `/bin/grep "^INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
        do
                label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
                value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"

                if ( [ "${label}" = "host" ] )
                then
                        /bin/sed -i "s/XXXXhostXXXX/${HOST}/" ${HOME}/runtime/application_db.dat
                elif ( [ "${label}" = "port" ] )
                then
                        /bin/sed -i "s/XXXXportXXXX/${DB_PORT}/" ${HOME}/runtime/application_db.dat
                elif ( [ "${label}" = "prefix" ] )
                then
                        /bin/sed -i "s/XXXXprefixXXXX/${db_prefix}/" ${HOME}/runtime/application_db.dat
                elif ( [ "${label}" = "driver" ] )
                then
                        :
                elif ( [ "`/bin/grep ${label} ${HOME}/runtime/application_db.dat`" != "" ] )
                then
                        if ( [ "${label}" = "prefix" ] )
                        then
                                value="${db_prefix}"
                        fi
                        /bin/sed -i "s/XXXX${label}XXXX/${value}/" ${HOME}/runtime/application_db.dat
                elif ( [ "${label}" = "salt" ] ) 
                then
                        /usr/bin/curl "https://api.wordpress.org/secret-key/1.1/salt/" -o salts
                        /usr/bin/csplit ${HOME}/runtime/wp-config.php '/AUTH_KEY/' '/NONCE_SALT/+1'
                        /bin/cat xx00 salts xx02 > ${HOME}/runtime/wp-config.php
                        /bin/rm salts xx00 xx01 xx02                
                fi
        done

        if ( [ ! -f /var/www/html/dbp.dat ] )
        then
                ${HOME}/providerscripts/email/SendEmail.sh "DB PREFIX FILE ABSENT" "Failed to access db prefix file" "ERROR"
                exit
        fi

        /bin/grep "ADDITIONAL_SETTING:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}' >> ${HOME}/runtime/settings.php
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
then
        /bin/sed -i "s/XXXXdriverXXXX/mysql/" ${HOME}/runtime/application_db.dat
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
        /bin/sed -i "s/XXXXdriverXXXX/mysql/" ${HOME}/runtime/application_db.dat
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ])
then
        /bin/sed -i "s/XXXXdriverXXXX/pgsql/" ${HOME}/runtime/application_db.dat
fi

/bin/sed -i -e "/^\$databases = \[\];/{r ${HOME}/runtime/application_db.dat" -e 'd}' ${HOME}/runtime/settings.php

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
        #This is how we tell ourselves this is a wordpress application
        /bin/echo "DRUPAL" > /var/www/html/dba.dat
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

if ( [ -f ${HOME}/runtime/settings.php ] )
then
        /bin/chmod 600 ${HOME}/runtime/settings.php
        /bin/chown www-data:www-data ${HOME}/runtime/settings.php
        /usr/bin/php -ln ${HOME}/runtime/settings.php

        if ( [ "$?" = "0" ] )
        then
                /bin/mv  ${HOME}/runtime/settings.php /var/www/html/sites/default/settings.php
                /bin/chmod 600 /var/www/html/sites/default/settings.php 
                /bin/chown www-data:www-data /var/www/html/sites/default/settings.php
                /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
        fi
fi

if ( [ "`/bin/grep "^INTERACTIVE_APPLICATION_INSTALL:no" ${HOME}/runtime/application.dat`" != "" ] )
then
        username="`/bin/grep "APPLICATION_USERNAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/awk '{print $1}'`"
        password="`/bin/grep "APPLICATION_PASSWORD:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/awk '{print $1}'`"
        /bin/chmod 755 /usr/sbin/drush
        /bin/chmod 755 /var/www/html/vendor/drush/drush/drush
        /bin/chmod 755 /var/www/html/vendor/bin/drush.php
        /usr/sbin/drush site:install -y --account-name=${username} --account-pass=${password}
fi

if ( [ ! -f  ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy drupal configuration file to the live location during application initiation" "ERROR"
fi

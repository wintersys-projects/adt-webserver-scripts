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
set -x

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ "`/bin/grep "^INTERACTIVE_APPLICATION_INSTALL" ${HOME}/runtime/application.dat | /bin/sed 's/INTERACTIVE_APPLICATION_INSTALL://g' | /bin/sed 's/:/ /g'`" = "yes" ] )
then
        exit
fi

if ( [ -f /var/www/html/web/sites/default/settings.php ] )
then
        /bin/rm /var/www/html/web/sites/default/settings.php
fi

if ( [ -f /var/www/html/web/sites/default/default.settings.php ] )
then
        /bin/cp /var/www/html/web/sites/default/default.settings.php /var/www/html/web/sites/default/settings.php.default
        /bin/chown www-data:www-data /var/www/html/web/settings.php.default
fi

/bin/cp /var/www/html/web/sites/default/settings.php.default /var/www/html/web/sites/default/settings.php

if ( [ -f /var/www/html/dbp.dat ] )
then
        dbprefix="`/bin/cat /var/www/html/dbp.dat`"
else
        dbprefix="adt`/usr/bin/tr -dc a-z0-9 </dev/urandom | /usr/bin/head -c 5; /bin/echo`_"
        /bin/echo ${dbprefix} > /var/www/html/dbp.dat
        /bin/chown www-data:www-data /var/www/html/dbp.dat
        /bin/chmod 600 /var/www/html/dbp.dat
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
        HOST="'`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`'"
else
        HOST="'`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`'"
fi

DB_PORT="'`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`'"


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
                directory="/var/www/html/${directory}"

                if ( [ ! -d ${directory} ] )
                then
                        /bin/mkdir -p ${directory}
                        /bin/echo "${directory}" >> ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing/exclusion_list.dat
                fi

                while ( [ "${directory}" != "/var/www/html" ] )
                do
                        /bin/chmod 755 ${directory}
                        /bin/chown www-data:www-data ${directory}
                        directory=`/usr/bin/dirname "${directory}"`
                done
        done

        #This is how we tell ourselves this is a joomla application
        /bin/echo "DRUPAL" > /var/www/html/dba.dat
        /bin/chown www-data:www-data /var/www/html/dba.dat

        if ( [ -f ${HOME}/runtime/overridehtaccess/htaccess.conf ] )
        then
                /bin/cp ${HOME}/runtime/overridehtaccess/htaccess.conf /var/www/html/web/.htaccess 
                /bin/chmod 444 /var/www/html/web/.htaccess
                /bin/chown www-data:www-data /var/www/html/web/.htaccess
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

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
        then
                driver="'mysql'"
        fi

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
        then
                driver="'mysql'"
        fi

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
        then
                driver="'pgsql'"
        fi


        username="'`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:username" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`'"
        password="'`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:password" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`'"
        database="'`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:database" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`'"
        collation="'`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:collation" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`'"

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
        then
                application_username="`/bin/grep "APPLICATION_USERNAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/awk '{print $1}'`"
                application_password="`/bin/grep "APPLICATION_PASSWORD:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/awk '{print $1}'`"

                /bin/chmod 755 /usr/sbin/drush
                if ( [ -f /var/www/html/vendor/bin/drush.php ] )
                then
                        /bin/chmod 755 /var/www/html/vendor/drush/drush/drush
                        /bin/chmod 755 /var/www/html/vendor/bin/drush.php
                elif ( [ -f /var/www/vendor/bin/drush.php ] )
                then
                        /bin/chmod 755 /var/www/vendor/drush/drush/drush
                        /bin/chmod 755 /var/www/vendor/bin/drush.php
                fi

               # /bin/sed -i 's/^$databases.*;/\$databases['\''default'\'']['\''default'\''] = ['\''username'\'' => '${username}', '\''password'\'' => '${password}', '\''database'\'' => '${database}', '\''host'\'' => '${HOST}', '\''port'\'' => '${DB_PORT}', '\''driver'\'' => '${driver}', '\''collation'\'' => '${collation}', ];/' /var/www/html/web/sites/default/settings.php
              #  /bin/grep "ADDITIONAL_SETTING:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}' >> /var/www/html/web/sites/default/settings.php
              #  /usr/sbin/drush site:install -y --account-name=${application_username} --account-pass=${application_password}
        
                /usr/sbin/drush site:install -y --account-name=${application_username} --account-pass=${application_password} --db-url=${driver}://${username}:${password}@${HOST}:${DB_PORT}/${database}
                /bin/grep "ADDITIONAL_SETTING:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}' >> /var/www/html/web/sites/default/settings.php
        else
                APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
                if ( [ "`/bin/cat /var/www/html/dba.dat`" != "`/bin/echo ${APPLICATION} | /bin/tr '[:lower:]' '[:upper:]'`" ] )
                then 
                        ${HOME}/providerscripts/email/SendEmail.sh "APPLICATION TYPE MISMATCH" "Your template thinks it is a different application type to your webroot" "ERROR"
                fi

                /bin/sed -i 's/^$databases.*;/\$databases['\''default'\'']['\''default'\''] = ['\''username'\'' => '${username}', '\''password'\'' => '${password}', '\''database'\'' => '${database}', '\''host'\'' => '${HOST}', '\''port'\'' => '${DB_PORT}', '\''driver'\'' => '${driver}', '\''collation'\'' => '${collation}', ];/' /var/www/html/web/sites/default/settings.php
                /bin/chmod 750 /usr/sbin/drush
                /bin/chmod 750 /var/www/html/vendor/drush/drush/drush
                /bin/chmod 750 /var/www/html/vendor/bin/drush.php
                /bin/sed -i "s%\$settings.*hash_salt.*;%\$settings['hash_salt'] = '`/usr/sbin/drush eval "echo Drupal\Component\Utility\Crypt::randomBytesBase64(55) . PHP_EOL"`';%" /var/www/html/web/sites/default/settings.php
                /bin/grep "ADDITIONAL_SETTING:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}' >> /var/www/html/web/sites/default/settings.php
        fi

        /usr/sbin/drush cache:rebuild

        /usr/bin/php -ln /var/www/html/web/sites/default/settings.php

        if ( [ "$?" = "0" ] )
        then
                /bin/chmod 600 /var/www/html/web/sites/default/settings.php
                /bin/chown www-data:www-data /var/www/html/web/sites/default/settings.php
                /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
        fi
fi

if ( [ ! -f  ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy drupal configuration file to the live location during application initiation" "ERROR"
fi

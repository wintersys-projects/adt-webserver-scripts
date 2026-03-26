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

webroot_directory="`/bin/grep "^WEBROOT_DIRECTORY:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${webroot_directory}" = "" ] )
then
        webroot_directory="/var/www/html/drupal"
fi


if ( [ -f ${webroot_directory}/sites/default/default.settings.php ] )
then
        /bin/cp ${webroot_directory}/sites/default/default.settings.php ${webroot_directory}/sites/default/settings.php
        /bin/chown www-data:www-data ${webroot_directory}/sites/default/settings.php
        /bin/cp ${webroot_directory}/sites/default/default.settings.php ${webroot_directory}/sites/default/settings.php.default
        /bin/chown www-data:www-data ${webroot_directory}/sites/default/settings.php.default
fi

if ( [ ! -f ${webroot_directory}/sites/default/settings.php ] )
then
        exit
fi

if ( [ -L ${webroot_directory}/sites/default/files ] )
then
        /bin/unlink ${webroot_directory}/sites/default/files
fi

config_file="`/bin/grep "^CONFIG_FILE:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${config_file}" = "" ] )
then
        config_file="/var/www/html/drupal/settings.php"
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ "`/bin/grep "^INTERACTIVE_APPLICATION_INSTALL" ${HOME}/runtime/application.dat | /bin/sed 's/INTERACTIVE_APPLICATION_INSTALL://g' | /bin/sed 's/:/ /g'`" = "yes" ] )
then
        if ( [ ! -f ${webroot_directory}/sites/default/settings.php ] )
        then
                while ( [ ! -f ${webroot_directory}/sites/default/settings.php ] )
                do
                        /bin/sleep 1
                done
        fi
        /bin/echo "`/bin/grep "prefix" ${webroot_directory}/configuration.php | /usr/bin/awk -F"'" '{print $4}'`" > /var/www/html/dbp.dat
        /bin/chown www-data:www-data /var/www/html/dbp.dat
else
        if ( [ -f ${config_file} ] )
        then
                /bin/rm ${config_file}
        fi
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
                HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
        else
                HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
        fi
        DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
        then
                HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
        else
                HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
        fi

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
                if ( [ -f ${webroot_directory}/bin/drush.php ] )
                then
                        /bin/chmod 755 ${webroot_directory}/vendor/drush/drush/drush
                        /bin/chmod 755 ${webroot_directory}/vendor/bin/drush.php
                elif ( [ -f /var/www/html/vendor/bin/drush.php ] )
                then
                        /bin/chmod 755 /var/www/html/vendor/drush/drush/drush
                        /bin/chmod 755 /var/www/html/vendor/bin/drush.php
                fi

                /bin/sed -i 's/^$databases.*;/\$databases['\''default'\'']['\''default'\''] = ['\''username'\'' => '${username}', '\''password'\'' => '${password}', '\''database'\'' => '${database}', '\''host'\'' => '\'${HOST}\'', '\''port'\'' => '${DB_PORT}', '\''driver'\'' => '${driver}', '\''collation'\'' => '${collation}', ];/' ${webroot_directory}/sites/default/settings.php
                /usr/sbin/drush site:install -y --account-name=${application_username} --account-pass=${application_password}
                /bin/grep "ADDITIONAL_SETTING:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}' >> ${webroot_directory}/sites/default/settings.php
                /bin/chown www-data:www-data ${webroot_directory}/sites/default/files
        else
                /bin/sed -i 's/^$databases.*;/\$databases['\''default'\'']['\''default'\''] = ['\''username'\'' => '${username}', '\''password'\'' => '${password}', '\''database'\'' => '${database}', '\''host'\'' => '\'${HOST}\'', '\''port'\'' => '${DB_PORT}', '\''driver'\'' => '${driver}', '\''collation'\'' => '${collation}', ];/' ${webroot_directory}/sites/default/settings.php
                /bin/chmod 750 /usr/sbin/drush
                /bin/chmod 750 ${webroot_directory}/vendor/drush/drush/drush
                /bin/chmod 750 ${webroot_directory}/vendor/bin/drush.php
                /bin/sed -i "s%\$settings.*hash_salt.*;%\$settings['hash_salt'] = '`/usr/sbin/drush eval "echo Drupal\Component\Utility\Crypt::randomBytesBase64(55) . PHP_EOL"`';%" ${webroot_directory}/sites/default/settings.php
                /bin/grep "ADDITIONAL_SETTING:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}' >> ${webroot_directory}/sites/default/settings.php

                APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
                if ( [ "`/bin/cat /var/www/html/dba.dat`" != "`/bin/echo ${APPLICATION} | /bin/tr '[:lower:]' '[:upper:]'`" ] )
                then 
                        ${HOME}/providerscripts/email/SendEmail.sh "APPLICATION TYPE MISMATCH" "Your template thinks it is a different application type to your webroot" "ERROR"
                fi
        fi

        /usr/sbin/drush cache:rebuild
fi

#This is how we tell ourselves this is a drupal application
/bin/echo "DRUPAL" > /var/www/html/dba.dat
/bin/chown www-data:www-data /var/www/html/dba.dat

if ( [ -f ${HOME}/runtime/overridehtaccess/htaccess.conf ] )
then
        /bin/cp ${HOME}/runtime/overridehtaccess/htaccess.conf ${webroot_directory}/.htaccess 
        /bin/chmod 444 ${webroot_directory}/.htaccess
        /bin/chown www-data:www-data ${webroot_directory}/.htaccess
fi

if ( [ -f ${webroot_directory}/sites/default/settings.php ] )
then
        /bin/mv ${webroot_directory}/sites/default/settings.php ${config_file}
        /bin/chown www-data:www-data ${config_file}
        /bin/chown 740 ${config_file}
fi

/bin/echo "<?php require( '${config_file}' ); ?>" > ${webroot_directory}/sites/default/settings.php

/bin/chown www-data:www-data ${webroot_directory}/sites/default/settings.php
/bin/chmod 400 ${webroot_directory}/sites/default/settings.php

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

if ( [ "`/bin/grep "^ASSETS_OUTSIDE_WEBROOT:yes" ${HOME}/runtime/application.dat`" != "" ] )
then
        if ( [ ! -d /var/www/html/files ] )
        then
                /bin/mv ${webroot_directory}/sites/default/files /var/www/html        
        fi

        /bin/ln -s /var/www/html/files ${webroot_directory}/sites/default/files
        /bin/chown www-data:www-data ${webroot_directory}/sites/default/files
        /bin/chmod 777 ${webroot_directory}/sites/default/files
fi

/usr/bin/php -ln ${config_file}

if ( [ "$?" = "0" ] )
then
        /bin/chmod 600 ${config_file}
        /bin/chown www-data:www-data ${config_file}
        /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
fi

if ( [ ! -f  ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"
fi


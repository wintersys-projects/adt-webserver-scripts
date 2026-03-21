#!/bin/sh
###########################################################################################################
# Description:This script will generate a /var/www/html/wp-config.php using the values that you have set in
#
#        ${BUILD_HOME}/application/descriptors/wordpress.dat
#
# If a virgin copy of wordpress is being installed, then, /usr/local/bin/wp is used
# when making a non-interactive installation this means that the installer doesn't have to do anything once they 
# have started the build they next thing they will see is a fully configured virgin wordpress application. 
# If you are deploying a baseline or a temporal backup then the configuration.php file is manually generated
# based on the values set in 
#
#         ${BUILD_HOME}/application/descriptors/wordpress.dat
#
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
#######################################################################################################
#set -x 

webroot_directory="`/bin/grep "^WEBROOT_DIRECTORY:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${webroot_directory}" = "" ] )
then
        webroot_directory="/var/www/html/wordpress"
fi

config_file="`/bin/grep "^CONFIG_FILE:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${config_file}" = "" ] )
then
        config_file="/var/www/html/wp-config.php"
fi

if ( [ -f ${webroot_directory}/wp-config.php ] )
then
        /bin/rm ${webroot_directory}/wp-config.php
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ "`/bin/grep "^INTERACTIVE_APPLICATION_INSTALL" ${HOME}/runtime/application.dat | /bin/sed 's/INTERACTIVE_APPLICATION_INSTALL://g' | /bin/sed 's/:/ /g'`" = "yes" ] )
then
        if ( [ ! -f ${webroot_directory}/wp-config.php ] )
        then
                while ( [ ! -f ${webroot_directory}/wp-config.php ] )
                do
                        /bin/sleep 1
                done
        fi
else
        if ( [ -f ${config_file} ] )
        then
                /bin/rm ${config_file}
        fi

        if ( [ -f /var/www/html/dbp.dat ] )
        then
                table_prefix="`/bin/cat /var/www/html/dbp.dat`"
        else
                table_prefix="adt`/usr/bin/tr -dc a-z0-9 </dev/urandom | /usr/bin/head -c 5; /bin/echo`_"
                /bin/echo ${table_prefix} > /var/www/html/dbp.dat
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

        WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
        website_name="`/bin/grep "^WEBSITE_NAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
        website_username="`/bin/grep "^WEBSITE_USERNAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
        website_password="`/bin/grep "^WEBSITE_PASSWORD:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
        webmaster_email="`/bin/grep "^WEBMASTER_EMAIL:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
        website_user_description="`/bin/grep "^WEBSITE_USER_DESCRIPTION:" ${HOME}/runtime/application.dat |  /usr/bin/awk -F':' '{print $NF}'`"
        db_user="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:DB_USER=" ${HOME}/runtime/application.dat |  /usr/bin/awk -F'=' '{print $NF}'`"
        db_password="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:DB_PASSWORD=" ${HOME}/runtime/application.dat |  /usr/bin/awk -F'=' '{print $NF}'`"
        db_name="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:DB_NAME=" ${HOME}/runtime/application.dat |  /usr/bin/awk -F'=' '{print $NF}'`"
        webroot_directory="`/bin/grep "^WEBROOT_DIRECTORY:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

        if ( [ "${webroot_directory}" = "" ] )
        then
                webroot_directory="/var/www/html/wordpress"
        fi

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
        then
                /usr/bin/sudo -u www-data /usr/local/bin/wp config create --dbuser="${db_user}" --dbpass="${db_password}" --dbname="${db_name}" --dbhost="${HOST}:${DB_PORT}" --dbprefix="${table_prefix}" --config-file="${webroot_directory}/wp-config.php" --path="${webroot_directory}"
                /usr/bin/sudo -u www-data /usr/local/bin/wp core install --url="${WEBSITE_URL}" --title="${website_name}" --admin_user="${website_username}" --admin_password="${website_password}" --admin_email="${webmaster_email}" --path="${webroot_directory}"
                /bin/mv ${webroot_directory}/wp-config.php ${config_file}
        else
                APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
                if ( [ "`/bin/cat /var/www/html/dba.dat`" != "`/bin/echo ${APPLICATION} | /bin/tr '[:lower:]' '[:upper:]'`" ] )
                then
                        ${HOME}/providerscripts/email/SendEmail.sh "APPLICATION TYPE MISMATCH" "Your template thinks it is a different application type to your webroot" "ERROR"
                        exit
                fi
                /usr/bin/sudo -u www-data /usr/local/bin/wp config create --dbuser="${db_user}" --dbpass="${db_password}" --dbname="${db_name}" --dbhost="${HOST}:${DB_PORT}" --dbprefix="${table_prefix}" --config-file="${config_file}" --path="${webroot_directory}"
        fi
fi

#This is how we tell ourselves this is a wordpress application
/bin/echo "WORDPRESS" > /var/www/html/dba.dat
/bin/chown www-data:www-data /var/www/html/dba.dat

if ( [ -f ${HOME}/runtime/overridehtaccess/htaccess.conf ] )
then
        /bin/cp ${HOME}/runtime/overridehtaccess/htaccess.conf ${webroot_directory}/.htaccess 
        /bin/chmod 444 ${webroot_directory}/.htaccess
        /bin/chown www-data:www-data ${webroot_directory}/.htaccess
fi

if ( [ -f ${webroot_directory}/wp-config.php ] )
then
        /bin/mv ${webroot_directory}/wp-config.php ${config_file}
        /bin/chown www-data:www-data ${config_file}
        /bin/chown 740 ${config_file}
fi

/bin/echo "<?php require( '${config_file}' ); ?>" > ${webroot_directory}/wp-config.php

/bin/chown www-data:www-data ${webroot_directory}/wp-config.php
/bin/chmod 440 ${webroot_directory}/wp-config.php

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

for setting in `/bin/grep "^INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^INDIVIDUAL_SETTING://g' | /usr/bin/awk -F'::' '{print $NF}' | /bin/sed 's/^://g'`
do
        label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
        value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $NF}'`"
        if ( [ "${label}" != "" ] && [ "${value}" != "" ] )
        then
                /usr/bin/sudo -u www-data wp config set "${label}" "${value}" --config-file="${config_file}"
        fi
done

if ( [ ! -d /var/www/html/wp-content ] )
then
        /bin/mv ${webroot_directory}/wp-content /var/www/html
        /bin/ln -s /var/www/html/wp-content ${webroot_directory}/wp-content
        /bin/chown www-data:www-data ${webroot_directory}/wp-content
        /bin/chmod 777 ${webroot_directory}/wp-content
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
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy wordpress configuration file to the live location during application initiation" "ERROR"
fi

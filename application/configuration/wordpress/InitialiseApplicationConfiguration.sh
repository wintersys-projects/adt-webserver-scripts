#!/bin/sh
###########################################################################################################
# Description:This script will generate a /var/www/configuration.php using the values that you have set in
#
#        ${BUILD_HOME}/application/descriptors/wordpress.dat
#
# If a virgin copy of wordpress is being installed, then, /usr/bin/php /var/www/html/installation/joomla.php is used
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

/bin/echo "<?php
/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');
/** Location of your WordPress configuration. */
require_once(ABSPATH . '../wp-config.php');" > /var/www/html/wordpress/wp-config.php
/bin/chown www-data:www-data /var/www/html/wordpress/wp-config.php
/bin/chown 440 /var/www/html/wordpress/wp-config.php

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ "`/bin/grep "^INTERACTIVE_APPLICATION_INSTALL" ${HOME}/runtime/application.dat | /bin/sed 's/INTERACTIVE_APPLICATION_INSTALL://g' | /bin/sed 's/:/ /g'`" = "yes" ] )
then
        exit
fi

if ( [ -f /var/www/html/wp-config.php ] )
then
        /bin/rm /var/www/html/wp-config.php
fi

if ( [ -f /var/www/html/wp-config-sample.php ] )
then
        /bin/cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php.default
        /bin/chown www-data:www-data /var/www/html/wp-config.php.default
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
website_user_description="`/bin/grep "^WEBSITE_USER_DESCRIPTION:" ${HOME}/runtime/application.dat |  /usr/bin/awk -F':' '{print $NF}'`"
db_user="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:DB_USER=" ${HOME}/runtime/application.dat |  /usr/bin/awk -F'=' '{print $NF}'`"
db_password="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:DB_PASSWORD=" ${HOME}/runtime/application.dat |  /usr/bin/awk -F'=' '{print $NF}'`"
db_name="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:DB_NAME=" ${HOME}/runtime/application.dat |  /usr/bin/awk -F'=' '{print $NF}'`"

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
        #This is how we tell ourselves this is a wordpress application
        /bin/echo "WORDPRESS" > /var/www/html/dba.dat
        /bin/chown www-data:www-data /var/www/html/dba.dat

        if ( [ -f ${HOME}/runtime/overridehtaccess/htaccess.conf ] )
        then
                /bin/cp ${HOME}/runtime/overridehtaccess/htaccess.conf /var/www/html/.htaccess 
                /bin/chmod 444 /var/www/html/.htaccess
                /bin/chown www-data:www-data /var/www/html/.htaccess
        fi

        /usr/bin/sudo -u www-data /usr/local/bin/wp config create --dbuser="${db_user}" --dbpass="${db_password}" --dbname="${db_name}" --dbhost="${HOST}:${DB_PORT}" --dbprefix="${table_prefix}" --config-file="/var/www/html/wp-config.php" --path="/var/www/html/wordpress"
        /usr/bin/sudo -u www-data /usr/local/bin/wp core install --url="${WEBSITE_URL}" --title="${website_name}" --admin_user="${website_username}" --admin_password="${website_password}" --admin_email="changeme@adt-installation-bootstrap.uk" --path="/var/www/html/wordpress" 

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
else
        APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
        if ( [ "`/bin/cat /var/www/html/dba.dat`" != "`/bin/echo ${APPLICATION} | /bin/tr '[:lower:]' '[:upper:]'`" ] )
        then 
                ${HOME}/providerscripts/email/SendEmail.sh "APPLICATION TYPE MISMATCH" "Your template thinks it is a different application type to your webroot" "ERROR"
        fi
        /usr/bin/sudo -u www-data /usr/local/bin/wp config create --dbuser="${db_user}" --dbpass="${db_password}" --dbname="${db_name}" --dbhost="${HOST}:${DB_PORT}" --dbprefix="${table_prefix}" --config-file="/var/www/html/wp-config.php" --path="/var/www/html/wordpress"
fi

for setting in `/bin/grep "^INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
do
        label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
        value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"
        if ( [ "${label}" != "" ] && [ "${value}" != "" ] )
        then
                /usr/bin/sudo -u www-data wp config set ${label} ${value} --config-file="/var/www/html/wp-config.php"
        fi
done

/usr/bin/php -ln /var/www/html/wp-config.php

if ( [ "$?" = "0" ] )
then                
        /bin/chmod 600 /var/www/html/wp-config.php
        /bin/chown www-data:www-data /var/www/html/wp-config.php
        /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
fi

if ( [ ! -f  ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy wordpress configuration file to the live location during application initiation" "ERROR"
fi

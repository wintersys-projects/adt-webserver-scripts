#!/bin/sh
###########################################################################################################
# Description:This script will generate a /var/www/html/config.php using the values that you have set in
#
#        ${BUILD_HOME}/application/descriptors/moodle.dat
#
# If a virgin copy of moodle is being installed, then, /usr/bin/php /var/www/html/admin/cli/install_database.php is used
# when making a non-interactive installation this means that the installer doesn't have to do anything once they 
# have started the build they next thing they will see is a fully configured virgin moodle application. 
# If you are deploying a baseline or a temporal backup then the config.php file is manually generated
# based on the values set in 
#
#         ${BUILD_HOME}/application/descriptors/moodle.dat
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
        webroot_directory="/var/www/html/moodle"
fi

if ( [ -f ${webroot_directory}/config-dist.php ] )
then
        /bin/cp ${webroot_directory}/config-dist.php /var/www/html/config.php.default
        /bin/chown www-data:www-data /var/www/html/config.php.default
fi

#if ( [ -L ${webroot_directory}/images ] )
#then
#        /bin/unlink ${webroot_directory}/images
#fi

config_file="`/bin/grep "^CONFIG_FILE:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${config_file}" = "" ] )
then
        config_file="/var/www/html/config.php"
fi

if ( [ -f ${webroot_directory}/config.php ] )
then
        /bin/rm ${webroot_directory}/config.php
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ "`/bin/grep "^INTERACTIVE_APPLICATION_INSTALL" ${HOME}/runtime/application.dat | /bin/sed 's/INTERACTIVE_APPLICATION_INSTALL://g' | /bin/sed 's/:/ /g'`" = "yes" ] )
then
        if ( [ ! -f ${webroot_directory}/config.php ] )
        then
                while ( [ ! -f ${webroot_directory}/config.php ] )
                do
                        /bin/sleep 1
                done
        fi
        /bin/echo "`/bin/grep "\$CFG->prefix" ${webroot_directory}/config.php | /usr/bin/awk -F"'" '{print $2}'`" > /var/www/html/dbp.dat
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
                dbprefix="adt`/usr/bin/tr -dc a-z </dev/urandom | /usr/bin/head -c 5; /bin/echo`_"
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

        user="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:user=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"
        password="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:password=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"
        db="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:db=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
        then
                type="mysqli"
        fi

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
        then
                type="mysqli"
        fi

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
        then
                type="pgsql"
        fi

        application_username="`/bin/grep "^APPLICATION_USERNAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
        application_password="`/bin/grep "^APPLICATION_PASSWORD:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
        application_fullname="`/bin/grep "^APPLICATION_FULLNAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
        application_shortname="`/bin/grep "^APPLICATION_SHORTNAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
        dbuser="`/bin/grep '^MANDATORY_INDIVIDUAL_SETTING:dbuser=' ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`"
        dbpass="`/bin/grep '^MANDATORY_INDIVIDUAL_SETTING:dbpass=' ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`"
        dbname="`/bin/grep '^MANDATORY_INDIVIDUAL_SETTING:dbname=' ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}'`"

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
        then
                dbtype="mariadb"
        elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
        then
                dbtype="mysqli"
        elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ])
        then
                dbtype="pgsql"
        fi

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
        then
                if ( [ -f /var/www/html/config.php ] )
                then
                        /bin/rm /var/www/html/config.php
                fi

                PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
                /bin/sed -i 's/.*max_input_vars.*/max_input_vars = 6000/' /etc/php/${PHP_VERSION}/cli/php.ini
                WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
                /usr/bin/sudo -u www-data /usr/bin/php /var/www/html/moodle/admin/cli/install.php --agree-license --non-interactive --adminuser="${application_username}" --adminpass="${application_password}" --adminemail="changeme@adt-installation-bootstrap.uk" --dbport="${DB_PORT}" --dbhost="${HOST}" --dbuser="${dbuser}" --dbpass="${dbpass}" --dbname="${dbname}" --dbtype="${dbtype}" --prefix="${dbprefix}" --wwwroot="https://${WEBSITE_URL}" --dataroot="/var/www/html/moodledata" --fullname="${application_fullname}" --shortname="${application_shortname}" 
        else
                /bin/sed -i "s%\$CFG->dbuser.*$%\$CFG->dbuser = '${dbuser}';%" /var/www/html/config.php
                /bin/sed -i "s%\$CFG->dbpass.*$%\$CFG->dbpass = '${dbpass}';%" /var/www/html/config.php
                /bin/sed -i "s%\$CFG->dbname.*$%\$CFG->dbname = '${dbname}';%" /var/www/html/config.php
                /bin/sed -i "s%\$CFG->dbhost.*$%\$CFG->dbhost = '${HOST}';%" /var/www/html/config.php
                /bin/sed -i "s%\$CFG->prefix.*$%\$CFG->prefix = '${dbprefix}';%" /var/www/html/config.php
                /bin/sed -i "1,/dbport/s/.*dbport.*/'dbport'    => '${DB_PORT}',/"  /var/www/html/config.php
                WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
                /bin/sed -i "s%\$CFG->wwwroot.*$%\$CFG->wwwroot = 'https://${WEBSITE_URL}';%" /var/www/html/config.php
                /bin/sed -i "s%\$CFG->dataroot.*$%\$CFG->dataroot = '/var/www/html/moodledata';%" /var/www/html/config.php

                if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
                then
                        /bin/sed -i 's/$CFG->dbtype.*$/$CFG->dbtype = "mariadb";/g' /var/www/html/config.php
                elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
                then
                        /bin/sed -i 's/$CFG->dbtype.*$/$CFG->dbtype = "mysqli";/g' /var/www/html/config.php
                elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ])
                then
                        /bin/sed -i 's/$CFG->dbtype.*$/$CFG->dbtype = "pgsql";/g' /var/www/html/config.php
                fi

                APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
                if ( [ "`/bin/cat /var/www/html/dba.dat`" != "`/bin/echo ${APPLICATION} | /bin/tr '[:lower:]' '[:upper:]'`" ] )
                then 
                        ${HOME}/providerscripts/email/SendEmail.sh "APPLICATION TYPE MISMATCH" "Your template thinks it is a different application type to your webroot" "ERROR"
                fi
        fi
fi

#This is how we tell ourselves this is a moodle application
/bin/echo "MOODLE" > /var/www/html/dba.dat
/bin/chown www-data:www-data /var/www/html/dba.dat

if ( [ -f ${HOME}/runtime/overridehtaccess/htaccess.conf ] )
then
        /bin/cp ${HOME}/runtime/overridehtaccess/htaccess.conf /var/www/html/.htaccess 
        /bin/chmod 444 /var/www/html/.htaccess
        /bin/chown www-data:www-data /var/www/html/.htaccess
fi

#if ( [ -f ${webroot_directory}/config.php ] )
#then
#        /bin/mv ${webroot_directory}/config.php ${config_file}
#        /bin/chown www-data:www-data ${config_file}
#        /bin/chown 740 ${config_file}
#fi

#/bin/echo "<?php require( '${config_file}' ); ?>" > ${webroot_directory}/config.php
#/bin/chown www-data:www-data ${webroot_directory}/config.php
#/bin/chmod 440 ${webroot_directory}/config.php

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

#if ( [ "`/bin/grep "^ASSETS_OUTSIDE_WEBROOT:yes" ${HOME}/runtime/application.dat`" != "" ] )
#then
#        if ( [ ! -d /var/www/html/images ] )
#        then
#                /bin/mv ${webroot_directory}/images /var/www/html        
#        fi
#
#        /bin/ln -s /var/www/html/images ${webroot_directory}/images
#        /bin/chown www-data:www-data ${webroot_directory}/images
#        /bin/chmod 777 ${webroot_directory}/images
#fi

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

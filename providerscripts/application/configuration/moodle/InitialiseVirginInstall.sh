#!/bin/sh
#####################################################################################
# Description: This script will initialise a virgin copy of moodle
# Author: Peter Winter
# Date: 04/01/2017
#######################################################################################
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
#######################################################################################
#######################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else

    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/*`" = "" ] )
    then
        exit
    fi
    HOST="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/*`"
fi

/bin/echo "${0} `/bin/date`: DB hostname set to ${HOST}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

DATABASE="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
PASSWORD="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
NAME="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

if ( [ "${NAME}" = "" ] || [ "${PASSWORD}" = "" ] || [ "${DATABASE}" = "" ] || [ "${HOST}" = "" ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/VIRGINCONFIGSET ] )
then
    exit
fi

#Get the port that the database is running on
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

/bin/echo "${0} `/bin/date`: DB port ${DB_PORT}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

#Set a prefix for our database tables. Make sure we only ever set one in the case where the script runs more than once
#and exits for some reason.
if ( [ ! -f /var/www/html/dbp.dat ] )
then
    prefix="p`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-6 | /usr/bin/tr '[:upper:]' '[:lower:]'`x_"
    if ( [ "${prefix}" != "" ] )
    then
        ${HOME}/providerscripts/utilities/StoreConfigValue.sh "DBPREFIX" "${prefix}"
        /bin/echo "${prefix}" > /var/www/html/dbp.dat
    fi
else
    prefix="`/bin/cat /var/www/html/dbp.dat`"
fi

/bin/echo "${0} `/bin/date`: DB prefix set to ${prefix}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/moodle-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data:www-data /var/www/html/.htaccess
    /bin/chmod 440 /var/www/html/.htaccess
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
    exit
fi

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/moodle-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data:www-data /var/www/html/.htaccess
    /bin/chmod 600 /var/www/html/.htaccess
fi

if ( [ ! -d /var/www/html/moodledata ] )
then
    /bin/mkdir -p /var/www/html/moodledata/filedir
    /bin/chmod -R 755 /var/www/html/moodledata
    /bin/chown -R www-data:www-data /var/www/html/moodledata
fi

#Set session handler to be database. May (will) get issues if trying to use filesystem
/bin/sed -i '/\/\/.*\\core\\session\\database/s/^\/\///' ${HOME}/runtime/moodle_config.php
/bin/sed -i '/\/\/.*session_database_acquire_lock_timeout/s/^\/\///' ${HOME}/runtime/moodle_config.php

/bin/echo "${0} `/bin/date`: set session database configurations" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" ${HOME}/runtime/moodle_config.php
        /bin/echo "For your information, this website uses MariaDB" > /var/www/html/dbe.dat
        /bin/echo "${0} `/bin/date`: set dbtype to mariadb" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" ${HOME}/runtime/moodle_config.php
        /bin/echo "For your information, this website uses MySQL" > /var/www/html/dbe.dat
        /bin/echo "${0} `/bin/date`: set dbtype to mysqli" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" ${HOME}/runtime/moodle_config.php
        /bin/echo "For your information, this website uses Postgres" > /var/www/html/dbe.dat
        /bin/echo "${0} `/bin/date`: set dbtype to pgsql" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    fi
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" ${HOME}/runtime/moodle_config.php
    /bin/echo "For your information, this website uses MariaDB" > /var/www/html/dbe.dat
    /bin/echo "${0} `/bin/date`: set dbtype to mariadb" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" ${HOME}/runtime/moodle_config.php
    /bin/echo "For your information, this website uses MySQL" > /var/www/html/dbe.dat
    /bin/echo "${0} `/bin/date`: set dbtype to mysqli" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" ${HOME}/runtime/moodle_config.php
    /bin/echo "For your information, this website uses Postgres" > /var/www/html/dbe.dat
    /bin/echo "${0} `/bin/date`: set dbtype to pgsql" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

if ( [ "`/bin/grep "${NAME}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbuser /c\    \$CFG->dbuser    = \"${NAME}\";" ${HOME}/runtime/moodle_config.php
    /bin/echo "${0} `/bin/date`: setting db username" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi
if ( [ "`/bin/grep "${DATABASE}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbname /c\    \$CFG->dbname    = \"${DATABASE}\";" ${HOME}/runtime/moodle_config.php
    /bin/echo "${0} `/bin/date`: setting dbname" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi
if ( [ "`/bin/grep "${PASSWORD}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbpass /c\    \$CFG->dbpass    = \"${PASSWORD}\";" ${HOME}/runtime/moodle_config.php
    /bin/echo "${0} `/bin/date`: setting dbpass" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi
if ( [ "${HOST}" = "127.0.0.1" ] || ( [ "`/bin/grep "${HOST}" ${HOME}/runtime/moodle_config.php`" = "" ]  && [ "${HOST}" != "" ] ) )
then
    /bin/sed -i "/->dbhost /c\    \$CFG->dbhost    = \"${HOST}\";" ${HOME}/runtime/moodle_config.php
    /bin/echo "${0} `/bin/date`: setting db hostname" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi
if ( [ "`/bin/grep "${prefix}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->prefix /c\    \$CFG->prefix    = \"${prefix}\";" ${HOME}/runtime/moodle_config.php
    /bin/echo "${0} `/bin/date`: setting db prefix" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi
if ( [ "`/bin/grep "dbport" ${HOME}/runtime/moodle_config.php | /bin/grep "${DB_PORT}"`" = "" ] )
then
    /bin/sed -i "/dbport/c\     \'dbport\' => \"${DB_PORT}\"," ${HOME}/runtime/moodle_config.php
    /bin/echo "${0} `/bin/date`: setting db port ${DB_PORT}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

websiteurl="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

if ( [ "`/bin/grep "wwwroot" ${HOME}/runtime/moodle_config.php | /bin/grep "${websiteurl}"`" = "" ] )
then
    /bin/sed -i "/\$CFG->wwwroot/c\     \$CFG->wwwroot    = \"https://${websiteurl}/moodle\";" ${HOME}/runtime/moodle_config.php
    /bin/echo "${0} `/bin/date`: setting wwwroot to https://${websiteurl}/moodle" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

if ( [ "`/bin/grep "moodledata" ${HOME}/runtime/moodle_config.php | /bin/grep "dataroot" | /bin/grep "\/var\/www\/html\/moodledata"`" = "" ] )
then
    /bin/sed -i "/\$CFG->dataroot/c\    \$CFG->dataroot    = '/var/www/html/moodledata';" ${HOME}/runtime/moodle_config.php
    /bin/echo "${0} `/bin/date`: setting dataroot to /var/www/html/moodledata" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

#/bin/echo "\$CFG->slasharguments = false;" >> ${HOME}/runtime/moodle_config.php 

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 
/bin/echo "${0} `/bin/date`: setting up SMTP" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( ( [ -f ${HOME}/runtime/moodle_config.php ] &&
    [ "${NAME}" != "" ] && [ "${PASSWORD}" != "" ] && [ "${DATABASE}" != "" ] && [ "${HOST}" != "" ] &&
    [ "`/bin/grep ${NAME} ${HOME}/runtime/moodle_config.php`" != "" ] &&
    [ "`/bin/grep ${PASSWORD} ${HOME}/runtime/moodle_config.php`" != "" ] &&
    [ "`/bin/grep ${DATABASE} ${HOME}/runtime/moodle_config.php`" != "" ] &&
    [ "`/bin/grep ${HOST} ${HOME}/runtime/moodle_config.php`" != "" ] ) )
then
     /bin/cp ${HOME}/runtime/moodle_config.php /var/www/html/moodle/config.php
     /bin/chmod 600 /var/www/html/moodle/config.php
     /bin/chown www-data:www-data /var/www/html/moodle/config.php
     /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
fi

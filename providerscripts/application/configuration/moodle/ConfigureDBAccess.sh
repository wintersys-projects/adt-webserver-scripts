#!/bin/sh
##################################################################################
# Description: This script will update update the database credentials for moodle
# Author: Peter Winter
# Date: 05/01/2017
###################################################################################
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

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh moodle_config.php`" != "" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh moodle_config.php ${HOME}/runtime/moodle_config.php.$$

    if ( [ "`/usr/bin/diff ${HOME}/runtime/moodle_config.php.$$ /var/www/html/moodle/config.php`" != "" ] )
    then
        /bin/mv ${HOME}/runtime/moodle_config.php.$$ /var/www/html/moodle/config.php
        /bin/cp /var/www/html/moodle/config.php ${HOME}/runtime/moodle_config.php
        /bin/chown www-data:www-data /var/www/html/moodle/config.php
        /bin/chmod 600 /var/www/html/moodle/config.php
    else
        /bin/rm ${HOME}/runtime/moodle_config.php.$$
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
    exit
fi

#This is the php temporary upload directory
if ( [ ! -d /var/www/html/tmp ] )
then
    /bin/mkdir -p /var/www/html/tmp
fi

if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    /bin/cp /var/www/html/moodle/config.php.default /var/www/html/moodle/config.php
fi

#Check that we have a prefix available, there must be an existing and well known prefix
dbprefix="`/bin/cat /var/www/html/dbp.dat`"
if ( [ "${dbprefix}" = "" ] )
then

    dbprefix="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*`"
fi
if ( [ "${dbprefix}" = "" ] )
then
    exit
fi
if ( [ "`/bin/grep ${dbprefix} ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->prefix /c\    \$CFG->prefix    = \"${dbprefix}\";" ${HOME}/runtime/moodle_config.php
    /bin/touch ${HOME}/runtime/moodle_config.php
    /bin/echo "${0} `/bin/date`: Updating the database prefix" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*`" != "" ] )
    then
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "DBPREFIX:*"
    fi
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh DBPREFIX:${dbprefix}    
fi

/bin/echo "${0} `/bin/date`: setting db prefix to ${dbprefix}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

websiteurl="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    DATABASE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSDBNAME'`"
    PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSPASSWORD'`"
    NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSUSERNAME'`"
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="${DBIP}"
fi

/bin/echo "${0} `/bin/date`: setting host to ${HOST}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log


if ( [ -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] && [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/moodle_config.php ] && 
    [ "${NAME}" != "" ] && [ "${DATABASE}" != "" ] && [ "${PASSWORD}" != "" ] && [ "${HOST}" != "" ] &&
    [ "`/bin/grep -- "${NAME}" ${HOME}/runtime/moodle_config.php`" != "" ]  &&
    [ "`/bin/grep -- "${DATABASE}" ${HOME}/runtime/moodle_config.php`" != "" ] &&
    [ "`/bin/grep -- "${PASSWORD}" ${HOME}/runtime/moodle_config.php `" != "" ]  &&
    [ "`/bin/grep -- "${HOST}" ${HOME}/runtime/moodle_config.php`" != "" ] &&
    [ "`/bin/grep "dbport" ${HOME}/runtime/moodle_config.php | /bin/grep "${DB_PORT}"`" != "" ] &&
    [ "`/bin/grep "dataroot" ${HOME}/runtime/moodle_config.php | /bin/grep "\/var\/www\/html\/moodledata"`" != "" ] &&
    [ "`/bin/grep "wwwroot" ${HOME}/runtime/moodle_config.php | /bin/grep "${websiteurl}"`" != "" ]  )
then
    /bin/touch ${HOME}/runtime/APPLICATION_DB_CONFIGURED
    /bin/cp ${HOME}/runtime/moodle_config.php /var/www/html/moodle/config.php
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/moodle_config.php moodle_config.php
    exit
else
    /bin/rm ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi   

/bin/chown -R www-data:www-data /var/www/html/moodledata

cd ${HOME}

#Set session handler to be database. May (will) get issues if trying to use filesystem
/bin/sed -i '/\/\/.*\\core\\session\\database/s/^\/\///' ${HOME}/runtime/moodle_config.php 
/bin/sed -i '/\/\/.*session_database_acquire_lock_timeout/s/^\/\///' ${HOME}/runtime/moodle_config.php 

/bin/echo "${0} `/bin/date`: setting database session values" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" ${HOME}/runtime/moodle_config.php 
        /bin/echo "${0} `/bin/date`: setting dbtype to mariadb" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" ${HOME}/runtime/moodle_config.php 
        /bin/echo "${0} `/bin/date`: setting dbtype to mysqli" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" ${HOME}/runtime/moodle_config.php 
        /bin/echo "${0} `/bin/date`: setting dbtype to pgsql" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    fi
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" ${HOME}/runtime/moodle_config.php 
    /bin/echo "${0} `/bin/date`: setting dbtype to mariadb" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" ${HOME}/runtime/moodle_config.php 
    /bin/echo "${0} `/bin/date`: setting dbtype to mysqli" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" ${HOME}/runtime/moodle_config.php 
    /bin/echo "${0} `/bin/date`: setting dbtype to pgsql" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

if ( [ -f ${HOME}/runtime/moodle_config.php ] && [ "`/bin/grep "${NAME}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbuser /c\    \$CFG->dbuser    = \"${NAME}\";" ${HOME}/runtime/moodle_config.php 
    /bin/echo "${0} `/bin/date`: setting dbuser" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

if ( [ -f ${HOME}/runtime/moodle_config.php ] && [ "`/bin/grep "${DATABASE}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbname /c\    \$CFG->dbname    = \"${DATABASE}\";" ${HOME}/runtime/moodle_config.php 
    /bin/echo "${0} `/bin/date`: setting dbname" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

if ( [ -f ${HOME}/runtime/moodle_config.php ] && [ "`/bin/grep "${PASSWORD}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbpass /c\    \$CFG->dbpass    = \"${PASSWORD}\";" ${HOME}/runtime/moodle_config.php 
    /bin/echo "${0} `/bin/date`: setting dbpass" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

if ( [ "${HOST}" = "127.0.0.1" ] || ( [ "`/bin/grep "${HOST}" ${HOME}/runtime/moodle_config.php`" = "" ]  && [ "${HOST}" != "" ] ) )
then
    /bin/sed -i "/->dbhost /c\    \$CFG->dbhost    = \"${HOST}\";" ${HOME}/runtime/moodle_config.php 
    /bin/echo "${0} `/bin/date`: setting dbhost" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

if ( [ -f ${HOME}/runtime/moodle_config.php ] && [ "`/bin/grep "dbport" ${HOME}/runtime/moodle_config.php | /bin/grep "${DB_PORT}"`" = "" ] )
then
    /bin/sed -i "/dbport/c\     \'dbport\' => \'${DB_PORT}\'," ${HOME}/runtime/moodle_config.php 
    /bin/echo "${0} `/bin/date`: setting dbport" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

if ( [ -f ${HOME}/runtime/moodle_config.php ] && [ "`/bin/grep "wwwroot" ${HOME}/runtime/moodle_config.php | /bin/grep "${websiteurl}"`" = "" ] )
then
    /bin/sed -i "0,/\$CFG->wwwroot/ s/\$CFG->wwwroot.*/\$CFG->wwwroot = \"https:\/\/${websiteurl}\/moodle\";/" ${HOME}/runtime/moodle_config.php 
    /bin/echo "${0} `/bin/date`: setting wwwroot to https://${websiteurl}/moodle" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

if ( [ -f ${HOME}/runtime/moodle_config.php ] && [ "`/bin/grep "moodledata" ${HOME}/runtime/moodle_config.php | /bin/grep "dataroot" | /bin/grep "\/var\/www\/html\/moodledata"`" = "" ] )
then
    /bin/sed -i "0,/\$CFG->dataroot/ s/\$CFG->dataroot.*/\$CFG->dataroot = \'\/var\/www\/html\/moodledata\';/" ${HOME}/runtime/moodle_config.php 
    /bin/echo "${0} `/bin/date`: setting dataroot to /var/www/html/moodledata" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

#/bin/echo "\$CFG->slasharguments = false;" >> ${HOME}/runtime/moodle_config.php 

if ( [ -f ${HOME}/runtime/moodle_config.php ] &&
    [ "${NAME}" != "" ] && [ "${PASSWORD}" != "" ] && [ "${DATABASE}" != "" ] && [ "${HOST}" != "" ] &&
    [ "`/bin/grep -- "${NAME}" ${HOME}/runtime/moodle_config.php`" != "" ] &&
    [ "`/bin/grep -- "${PASSWORD}" ${HOME}/runtime/moodle_config.php`" != "" ] &&
    [ "`/bin/grep -- "${DATABASE}" ${HOME}/runtime/moodle_config.php`" != "" ] &&
    [ "`/bin/grep -- "${HOST}" ${HOME}/runtime/moodle_config.php`" != "" ] )
then
    /bin/cp ${HOME}/runtime/moodle_config.php /var/www/html/moodle/config.php
    /bin/chown www-data:www-data /var/www/html/moodle/config.php
    /bin/chmod 600 /var/www/html/moodle/config.php
fi

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 
/bin/echo "${0} `/bin/date`: Setting SMTP values" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

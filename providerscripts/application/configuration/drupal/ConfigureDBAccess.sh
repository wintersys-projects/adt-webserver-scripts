#!/bin/sh
####################################################################################
# Description: This script will update update the database credentials for drupal
# Author: Peter Winter
# Date: 05/01/2017
####################################################################################
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
#####################################################################################
#####################################################################################
#set -x

if ( [ ! -d /var/www/html//sites/default/files/private ] )
then
    /bin/mkdir -p /var/www/html/sites/default/files/private
fi

#This is the php temporary upload directory
if ( [ ! -d /var/www/html/tmp ] )
then
    /bin/mkdir -p /var/www/html/tmp
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh drupal_settings.php`" != "" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh drupal_settings.php ${HOME}/runtime/drupal_settings.php.$$

    if ( [ "`/usr/bin/diff ${HOME}/runtime/drupal_settings.php.$$ /var/www/html/sites/default/settings.php`" != "" ] )
    then
        /bin/mv ${HOME}/runtime/drupal_settings.php.$$ /var/www/html/sites/default/settings.php
        /bin/cp /var/www/html/sites/default/settings.php ${HOME}/runtime/drupal_settings.php
        /bin/chown www-data:www-data /var/www/html/sites/default/settings.php
        /bin/chmod 600 /var/www/html/sites/default/settings.php
    else
        /bin/rm ${HOME}/runtime/drupal_settings.php.$$
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
    exit
fi

if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    /bin/cp /var/www/html/sites/default/default.settings.php ${HOME}/runtime/drupal_settings.php
fi

#Check that we have a prefix available, there must be an existing and well known prefix
prefix="`/bin/cat /var/www/html/dbp.dat`"
if ( [ "${prefix}" = "" ] )
then
    prefix="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*`"
fi
if ( [ "${prefix}" = "" ] )
then
    exit
fi
if ( [ "`/bin/grep ${prefix} ${HOME}/runtime/drupal_settings.php`" = "" ] )
then

    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*`" != "" ] )
    then
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "DBPREFIX:*"
    fi
    
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh DBPREFIX:${prefix}    
fi

/bin/echo "${0} `/bin/date`: DB prefix set to ${prefix}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="${DBIP}"
fi

/bin/echo "${0} `/bin/date`: DB hostname set to ${HOST}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( [ -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

if ( [ -f /var/www/html/sites/default/settings.php ] && 
    [ "${NAME}" != "" ] && [ "${PASSWORD}" != "" ] && [ "${DATABASE}" != "" ] && [ "${HOST}" != "" ] &&
    [ "`/bin/grep -- "${NAME}" /var/www/html/sites/default/settings.php`" != "" ] &&
    [ "`/bin/grep -- "${PASSWORD}" /var/www/html/sites/default/settings.php`" != "" ] &&
    [ "`/bin/grep -- "${DATABASE}" /var/www/html/sites/default/settings.php`" != "" ] &&
    [ "`/bin/grep -- "${HOST}" /var/www/html/sites/default/settings.php`" != "" ] )
then
    /bin/touch ${HOME}/runtime/APPLICATION_DB_CONFIGURED
    /bin/cp /var/www/html/sites/default/settings.php ${HOME}/runtime/drupal_settings.php
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/drupal_settings.php drupal_settings.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
    exit
else
    /bin/rm ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi


if ( [ -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] &&  [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ] )
then
    exit
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

/bin/echo "${0} `/bin/date`: DB port set to ${DB_PORT}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    DATABASE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSDBNAME'`"
    PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSPASSWORD'`"
    NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSUSERNAME'`"
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
fi

/usr/bin/perl -i -pe 'BEGIN{undef $/;} s/^\$databases.\;/\$databases = [];/smg' ${HOME}/runtime/drupal_settings.php

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${DATABASE}', \n 'username' => '${NAME}', \n 'password' => '${PASSWORD}', \n 'host' => '${HOST}', \n 'port' => '${DB_PORT}', \n 'driver' => 'pgsql', \n 'prefix' => '${prefix}', \n 'collation' => 'utf8mb4_general_ci',\n);"
    /bin/echo "${0} `/bin/date`: Set DB username, password, database name, hostname and port" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
else
    credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${DATABASE}', \n 'username' => '${NAME}', \n 'password' => '${PASSWORD}', \n 'host' => '${HOST}', \n 'port' => '${DB_PORT}', \n 'driver' => 'mysql', \n 'prefix' => '${prefix}', \n 'collation' => 'utf8mb4_general_ci',\n);"
    /bin/echo "${0} `/bin/date`: Set DB username, password, database name, hostname and port" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

/bin/sed -i "/^\$databases/{:1;/;/!{N;b 1}
     s/.*/${credentialstring}/g}" ${HOME}/runtime/drupal_settings.php

if ( [ ! -d /var/www/tmp ] )
then
    /bin/mkdir -p /var/www/tmp
fi

/bin/chmod 755 /var/www/tmp
/bin/chown www-data:www-data /var/www/tmp

/bin/sed -i "/.*$settings\['file_temp_path'\]/c\$settings['file_temp_path'] = '/var/www/tmp';" ${HOME}/runtime/drupal_settings.php
    
salt="`/bin/cat /var/www/html/salt`"
    
if ( [ "${salt}" = "" ] )
then
    salt="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
fi

/bin/sed -i "/^\$settings\['hash_salt'\]/c\$settings['hash_salt'] = '${salt}';" ${HOME}/runtime/drupal_settings.php

/bin/echo "${0} `/bin/date`: Set the salt value" >> ${HOME}/logs/OPERATIONAL_MONITORING.log


if ( [ "`/bin/grep 'ADDED BY CONFIG PROCESS' ${HOME}/runtime/drupal_settings.php`" = "" ] )
then
    /bin/echo "#====ADDED BY CONFIG PROCESS=====" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$settings['trusted_host_patterns'] = [ '.*' ];" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$settings['config_sync_directory'] = '/var/www/html/sites/default';" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$config['system.performance']['css']['preprocess'] = FALSE;" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$config['system.performance']['js']['preprocess'] = FALSE;" >> ${HOME}/runtime/drupal_settings.php 
    /bin/echo "\$settings['file_private_path'] = \$app_root . '/sites/default/files/private';" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "${0} `/bin/date`: Adjusted the drupal settings:  trusted_host_patterns, config_sync_directory, system.performance" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

if ( [ -f ${HOME}/runtime/drupal_settings.php ] &&
    [ "${NAME}" != "" ] && [ "${PASSWORD}" != "" ] && [ "${DATABASE}" != "" ] && [ "${HOST}" != "" ] &&
    [ "`/bin/grep -- "${NAME}" ${HOME}/runtime/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep -- "${PASSWORD}" ${HOME}/runtime/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep -- "${DATABASE}" ${HOME}/runtime/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep -- "${HOST}" ${HOME}/runtime/drupal_settings.php`" != "" ] )
then
    /bin/cp ${HOME}/runtime/drupal_settings.php /var/www/html/sites/default/settings.php
    /bin/chown www-data:www-data /var/www/html/sites/default/settings.php
    /bin/chmod 600 /var/www/html/sites/default/settings.php
fi

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 

/bin/echo "${0} `/bin/date`: Setup SMTP" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

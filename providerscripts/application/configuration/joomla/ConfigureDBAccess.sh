#!/bin/sh
##################################################################################
# Description: This script will update update the database credentials for joomla
# Author: Peter Winter
# Date: 05/01/2017
##################################################################################
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
#################################################################################
#################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh joomla_configuration.php`" != "" ] )
then
    /bin/sleep 5
    
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime/joomla_configuration.php.$$

    if ( [ "`/usr/bin/diff ${HOME}/runtime/joomla_configuration.php.$$ /var/www/html/configuration.php`" != "" ] )
    then
        /bin/mv ${HOME}/runtime/joomla_configuration.php.$$ /var/www/html/configuration.php
        /bin/cp /var/www/html/configuration.php ${HOME}/runtime/joomla_configuration.php
        /bin/chown www-data:www-data /var/www/html/configuration.php
        /bin/chmod 600 /var/www/html/configuration.php
    else
        /bin/rm ${HOME}/runtime/joomla_configuration.php.$$
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
    exit
fi

if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    /bin/cp /var/www/html/configuration.php.default ${HOME}/runtime/joomla_configuration.php
fi

#This is the php temporary upload directory
if ( [ ! -d /var/www/html/tmp ] )
then
    /bin/mkdir -p /var/www/html/tmp
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
if ( [ "`/bin/grep ${dbprefix} ${HOME}/runtime/joomla_configuration.php`" = "" ] )
then
    /bin/sed -i "/\$dbprefix /c\        public \$dbprefix = \'${dbprefix}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/touch ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating the database prefix" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*`" != "" ] )
    then
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "DBPREFIX:*"
    fi
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh DBPREFIX:${dbprefix}    
fi

/bin/echo "${0} `/bin/date`: db prefix set to: ${dbprefix}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="${DBIP}"
fi

/bin/echo "${0} `/bin/date`: db hostname set to: ${HOST}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( [ -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

if ( [ -f /var/www/html/configuration.php ] &&
    [ "${NAME}" != "" ] && [ "${PASSWORD}" != "" ] && [ "${DATABASE}" != "" ] && [ "${HOST}" != "" ] &&
    [ "`/bin/grep -- "${NAME}" /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep -- "${PASSWORD}" /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep -- "${DATABASE}" /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep -- "${HOST}" /var/www/html/configuration.php`" != "" ] )
then
    /bin/touch ${HOME}/runtime/APPLICATION_DB_CONFIGURED
    /bin/cp /var/www/html/configuration.php ${HOME}/runtime/joomla_configuration.php
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/joomla_configuration.php joomla_configuration.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
    /bin/cp /var/www/html/configuration.php ${HOME}/runtime/joomla_configuration.php
    exit
else
    /bin/rm ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] &&  [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    DATABASE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSDBNAME'`"
    PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSPASSWORD'`"
    NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSUSERNAME'`"
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
fi

#Set the credentials that we need
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"
DBIP_AND_PORT="${HOST}:${DB_PORT}"

/bin/echo "${0} `/bin/date`: db port set to: ${DB_PORT}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log


if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'pgsql\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating the database driver" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    /bin/sed -i "/\$port /d" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$host /c\        public \$host = \'${HOST}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$host /a        public \$port = \'${DB_PORT}\';" ${HOME}/runtime/joomla_configuration.php
else
    /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'mysqli\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating the database driver" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    /bin/sed -i "/\$host = /c\   public \$host = \'${DBIP_AND_PORT}\';" ${HOME}/runtime/joomla_configuration.php
fi

/bin/sed -i "/\$user/c\       public \$user = \'${NAME}\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the database user credential" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$password/c\   public \$password = \'${PASSWORD}\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the database password credential" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$db /c\        public \$db = \'${DATABASE}\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the database name credential" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$cachetime /c\        public \$cachetime = \'30\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the cache expiration time to 30" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'file\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the cache handler to 'file'" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$caching /c\        public \$caching = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the caching with value 1" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$sef /c\        public \$sef = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the sef to 0" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$sef_suffix /c\        public \$sef_suffix = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the sef_suffix to 0" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$sef_rewrite /c\        public \$sef_rewrite = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the sef_rewrite to 0" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$gzip /c\        public \$gzip = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the gzip to 1" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$force_ssl /c\        public \$force_ssl = \'2\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the force ssl to 2" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$shared_session /c\        public \$shared_session = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating shared session to 0" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$tmp_path /c\        public \$tmp_path = \'/var/www/html/tmp\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating tmp path" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
/bin/sed -i "/\$log_path /c\        public \$log_path = \'/var/www/html/logs\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating logs path" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh  

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh INMEMORYCACHING:memcache`" = "1" ] )
then
    /bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'memcache\';" ${HOME}/runtime/joomla_configuration.php
    cache_host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGHOST'`"
    cache_port="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGPORT'`"
    /bin/sed -i "/\$memcache_server_host /c\        public \$memcache_server_host = \'${cache_host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$memcache_server_port /c\        public \$memcache_server_port = \'${cache_port}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: set cache_handler to memcache" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    /bin/echo "${0} `/bin/date`: set memcache_server_host to ${cache_host}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    /bin/echo "${0} `/bin/date`: set memcache_server_port to ${cache_port}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    /bin/touch ${HOME}/runtime/GENERAL_CONFIG_UPDATED
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh INMEMORYCACHING:redis`" = "1" ] )
then
    /bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'redis\';" ${HOME}/runtime/joomla_configuration.php
    cache_host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGHOST'`"
    cache_port="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGPORT'`"
    /bin/sed -i "/\$redis_server_host /c\        public \$redis_server_host = \'${cache_host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$redis_server_port /c\        public \$redis_server_port = \'${cache_port}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: set cache_handler to redis" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    /bin/echo "${0} `/bin/date`: set redis_server_host to ${cache_host}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    /bin/echo "${0} `/bin/date`: set redis_server_port to ${cache_port}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    /bin/touch ${HOME}/runtime/GENERAL_CONFIG_UPDATED
fi

secret="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh SECRET:*  | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${secret}" = "" ] )
then
    secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh SECRET:${secret}    
fi

/bin/sed -i "/\$secret /c\        public \$secret = \'${secret}\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating secret" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( ( [ -f ${HOME}/runtime/joomla_configuration.php ] &&
    [ "${NAME}" != "" ] && [ "${PASSWORD}" != "" ] && [ "${DATABASE}" != "" ] && [ "${HOST}" != "" ] &&
    [ "`/bin/grep -- "${NAME}" ${HOME}/runtime/joomla_configuration.php`" != "" ] &&
    [ "`/bin/grep -- "${PASSWORD}" ${HOME}/runtime/joomla_configuration.php`" != "" ] &&
    [ "`/bin/grep -- "${DATABASE}" ${HOME}/runtime/joomla_configuration.php`" != "" ] &&
    [ "`/bin/grep -- "${HOST}" ${HOME}/runtime/joomla_configuration.php`" != "" ] ) ||  [ -f ${HOME}/runtime/GENERAL_CONFIG_UPDATED ] )
then
    /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
    /bin/chown www-data:www-data /var/www/html/configuration.php
    /bin/chmod 600 /var/www/html/configuration.php
    /bin/rm ${HOME}/runtime/GENERAL_CONFIG_UPDATED
fi

if ( [ -f /var/www/html/cli/garbagecron.php ] )
then
    /usr/bin/php /var/www/html/cli/garbagecron.php
else
    /usr/bin/php /var/www/html/cli/joomla.php cache:clean
fi

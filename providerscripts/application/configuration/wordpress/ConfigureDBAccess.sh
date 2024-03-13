#!/bin/sh
#####################################################################################
# Description: This script will update update the database credentials for wordpress
# Author: Peter Winter
# Date: 05/01/2017
#####################################################################################
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

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh wordpress_config.php`" != "" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh wordpress_config.php ${HOME}/runtime/wordpress_config.php.$$

    if ( [ "`/usr/bin/diff ${HOME}/runtime/wordpress_config.php.$$ /var/www/html/wp-config.php`" != "" ] )
    then
        /bin/mv ${HOME}/runtime/wordpress_config.php.$$ /var/www/html/wp-config.php
        /bin/chown www-data:www-data /var/www/html/wp-config.php
        /bin/chmod 600 /var/www/html/wp-config.php
    else
        /bin/rm ${HOME}/runtime/wordpress_config.php.$$
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
    /bin/cp /var/www/html/wp-config-sample.php ${HOME}/runtime/wordpress_config.php
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

if ( [ "`/bin/grep ${dbprefix} ${HOME}/runtime/wordpress_config.php`" = "" ] )
then
    /bin/sed -i "/\$table_prefix/c\ \$table_prefix=\"${dbprefix}\";" ${HOME}/runtime/wordpress_config.php
    /bin/touch ${HOME}/runtime/wordpress_config.php
    /bin/echo "${0} `/bin/date`: Updating the database prefix" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*`" != "" ] )
    then
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "DBPREFIX:*"
    fi
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh DBPREFIX:${dbprefix}    
fi

/bin/echo "${0} `/bin/date`: setting database prefix to ${dbprefix}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="${DBIP}"
fi

/bin/echo "${0} `/bin/date`: setting hostname to ${HOST}" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

if ( [ -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

if ( [ -f /var/www/html/wp-config.php ] && 
    [ "${NAME}" != "" ] && [ "${PASSWORD}" != "" ] && [ "${DATABASE}" != "" ] && [ "${HOST}" != "" ] &&
    [ "`/bin/grep -- "${NAME}" /var/www/html/wp-config.php`" != "" ] &&
    [ "`/bin/grep -- "${PASSWORD}" /var/www/html/wp-config.php`" != "" ] &&
    [ "`/bin/grep -- "${DATABASE}" /var/www/html/wp-config.php`" != "" ] &&
    [ "`/bin/grep -- "${HOST}" /var/www/html/wp-config.php`" != "" ] )
then
    /bin/touch ${HOME}/runtime/APPLICATION_DB_CONFIGURED
    /bin/cp /var/www/html/wp-config.php ${HOME}/runtime/wordpress_config.php
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/wordpress_config.php wordpress_config.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
    exit
else
    /bin/rm ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi
    

if ( [ -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] && [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ]  )
then
    exit
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    DATABASE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSDBNAME'`"
    PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSPASSWORD'`"
    NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSUSERNAME'`"
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
fi

/bin/sed -i "/DB_HOST/c\ define('DB_HOST', \"${HOST}:${DB_PORT}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database host name" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

/bin/sed -i "/DB_USER/c\ define('DB_USER', \"${NAME}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database user credential" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

/bin/sed -i "/DB_PASSWORD/c\ define('DB_PASSWORD', \"${PASSWORD}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database password credential" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

/bin/sed -i "/DB_NAME/c\ define('DB_NAME', \"${DATABASE}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database name" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

/bin/sed -i "/\$table_prefix/c\ \$table_prefix=\"${dbprefix}\";" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database table prefix" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 

/bin/echo "${0} `/bin/date`: setting up SMTP" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

#Sort the salts and switch the cache on
if ( [ "`/bin/grep SALTEDALREADY ${HOME}/runtime/wordpress_config.php`" = "" ] )
then
    /bin/echo "${0} `/bin/date`: setting up salts and caching" >> ${HOME}/logs/OPERATIONAL_MONITORING.log

    /bin/sed -i "/'AUTH_KEY'/i XXYYZZ" ${HOME}/runtime/wordpress_config.php
    /bin/sed -i '/AUTH_KEY/,+7d' ${HOME}/runtime/wordpress_config.php
    salts="`/usr/bin/curl https://api.wordpress.org/secret-key/1.1/salt`"
    /bin/sed -n '/XXYYZZ/q;p' ${HOME}/runtime/wordpress_config.php > /tmp/firsthalf
    /bin/sed '0,/^XXYYZZ$/d' ${HOME}/runtime/wordpress_config.php > /tmp/secondhalf
    /bin/cat /tmp/firsthalf > /tmp/fullfile
    /bin/echo ${salts} >> /tmp/fullfile
    /bin/echo "/* SALTEDALREADY */" >> /tmp/fullfile
    /bin/echo "define( 'DISALLOW_FILE_EDIT', true );" >> /tmp/fullfile
    /bin/echo "define( 'WP_DEBUG', false );" >> /tmp/fullfile
    /bin/echo "define('WP_CACHE', false);" >> /tmp/fullfile
    /bin/echo "define('CONCATENATE_SCRIPTS', true);" >> /tmp/fullfile
    /bin/echo "define('COMPRESS_SCRIPTS', true);" >> /tmp/fullfile
    /bin/echo "define('COMPRESS_CSS', true);" >> /tmp/fullfile
    /bin/echo "define('DISABLE_WP_CRON', true);" >> /tmp/fullfile
    /bin/cat /tmp/secondhalf >> /tmp/fullfile
    /bin/rm /tmp/firsthalf /tmp/secondhalf
    /bin/mv /tmp/fullfile ${HOME}/runtime/wordpress_config.php
fi

if ( [ -f ${HOME}/runtime/wordpress_config.php ] &&
    [ "${NAME}" != "" ] && [ "${PASSWORD}" != "" ] && [ "${DATABASE}" != "" ] && [ "${HOST}" != "" ] &&
    [ "`/bin/grep -- "${NAME}" ${HOME}/runtime/wordpress_config.php`" != "" ] &&
    [ "`/bin/grep -- "${PASSWORD}" ${HOME}/runtime/wordpress_config.php`" != "" ] &&
    [ "`/bin/grep -- "${DATABASE}" ${HOME}/runtime/wordpress_config.php`" != "" ] &&
    [ "`/bin/grep -- "${HOST}" ${HOME}/runtime/wordpress_config.php`" != "" ] )
then
    /bin/cp ${HOME}/runtime/wordpress_config.php /var/www/html/wp-config.php
    /bin/chown www-data:www-data /var/www/html/wp-config.php
    /bin/chmod 600 /var/www/html/wp-config.php
fi

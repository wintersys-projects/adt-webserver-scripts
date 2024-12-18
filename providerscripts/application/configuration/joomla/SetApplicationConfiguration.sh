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

#########test

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
        exit
fi

if ( [ ! -d ${HOME}/credentials ] )
then
    /bin/mkdir -p ${HOME}/credentials
    /bin/chmod 700 ${HOME}/credentials
fi    
if ( [ ! -f ${HOME}/runtime/CREDENTIALS_PRIMED ] && [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/db_cred"`" = "1" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh credentials/db_cred ${HOME}/credentials/db_cred
    if ( [ -f ${HOME}/credentials/db_cred ] )
    then
        /bin/touch ${HOME}/runtime/CREDENTIALS_PRIMED
    fi
fi

diff="`/usr/bin/diff /var/www/html/configuration.php ${HOME}/runtime/joomla_configuration.php`"

if ( ( [ ! -f ${HOME}/runtime/INITIAL_CONFIG_SET ] || [ "${diff}" != "" ] ) && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh joomla_configuration.php`" != "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime/joomla_configuration.php
        if ( [ "`/usr/bin/diff /var/www/html/configuration.php ${HOME}/runtime/joomla_configuration.php`" != "" ] )
        then
                /usr/bin/php -ln ${HOME}/runtime/joomla_configuration.php
                if ( [ "$?" = "0" ] )
                then
                        /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
                        /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
                fi
        fi
fi
exit
#######test


if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
        exit
fi


if ( [ ! -f ${HOME}/runtime/CONFIG_PRIMED ] && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh configuration.php.default`" = "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/www/html/configuration.php.default
        if ( [ "$?" = "0" ] )
        then
                /bin/touch ${HOME}/runtime/CONFIG_PRIMED
        fi
fi

if ( [ ! -f ${HOME}/runtime/JOOMLA_CONFIG_SET ] && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh joomla_configuration.php`" != "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime/joomla_configuration.php
        if ( [ -f /var/www/html/configuration.php ] )
        then
                /bin/rm /var/www/html/configuration.php
        fi
        /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
        /bin/touch ${HOME}/runtime/JOOMLA_CONFIG_SET
elif ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh joomla_configuration.php`" != "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime/joomla_configuration.php.$$
        if ( [ "`/usr/bin/diff ${HOME}/runtime/joomla_configuration.php.$$ /var/www/html/configuration.php`" != "" ] )
        then
                /bin/cp ${HOME}/runtime/joomla_configuration.php.$$ ${HOME}/runtime/joomla_configuration.php
                /bin/mv ${HOME}/runtime/joomla_configuration.php.$$ /var/www/html/configuration.php
        else
                /bin/rm ${HOME}/runtime/joomla_configuration.php.$$
        fi
fi

if ( [ -f /var/www/html/configuration.php ] )
then
        /bin/chown www-data:www-data /var/www/html/configuration.php
        /bin/chmod 600 /var/www/html/configuration.php
fi

if ( [ ! -f ${HOME}/runtime/DB_PREFIX_SET ] ||  [ ! -f ${HOME}/runtime/SECRET_SET ] )
then
        dbprefix="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*  | /usr/bin/awk -F':' '{print $NF}'`"

        if ( [ "${dbprefix}" = "" ] )
        then
                dbprefix="`/bin/cat /var/www/html/dbp.dat`"
        fi
 
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh DBPREFIX:${dbprefix}
        /bin/touch ${HOME}/runtime/DB_PREFIX_SET

        secret="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh SECRET:*  | /usr/bin/awk -F':' '{print $NF}'`"

        if ( [ "${secret}" = "" ] )
        then
                secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
        fi

        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh SECRET:${secret}    
        /bin/touch ${HOME}/runtime/SECRET_SET
fi


#!/bin/sh
#############################################################################
# Description: This script will initialise a virgin copy of drupal
# Author: Peter Winter
# Date: 04/01/2017
###############################################################################
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

if ( [ ! -d /var/www/tmp ] )
then
    /bin/mkdir -p /var/www/tmp
fi

/bin/chmod 755 /var/www/tmp
/bin/chown www-data:www-data /var/www/tmp

/bin/sed -i "/.*$settings\['file_temp_path'\]/c\$settings['file_temp_path'] = '/var/www/tmp';" /var/www/html/sites/default/settings.php

if ( [ -f /var/www/html/sites/default/settings.php ] && [ "`/bin/grep 'ADDED BY CONFIG PROCESS' /var/www/html/sites/default/settings.php`" = "" ] )
then
    /bin/echo "#====ADDED BY CONFIG PROCESS=====" >> /var/www/html/sites/default/settings.php
    /bin/echo "\$settings['trusted_host_patterns'] = [ '.*' ];" >> /var/www/html/sites/default/settings.php
    /bin/echo "\$settings['config_sync_directory'] = '/var/www/html/sites/default';" >> /var/www/html/sites/default/settings.php
    /bin/echo "\$config['system.performance']['css']['preprocess'] = FALSE;" >> /var/www/html/sites/default/settings.php
    /bin/echo "\$config['system.performance']['js']['preprocess'] = FALSE;" >> /var/www/html/sites/default/settings.php
    /bin/echo "\$settings['file_private_path'] = \$app_root . '/sites/default/files/private';" >> /var/www/html/sites/default/settings.php
    /bin/echo "${0} `/bin/date`: Adjusted the drupal settings: file_private_path, trusted_host_patterns, config_sync_directory, system.performance" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    /bin/cp /var/www/html/sites/default/settings.php ${HOME}/runtime/drupal_settings.php 
fi

if ( [ -f /var/www/html/sites/default/settings.php ] )
then
    dbprefix="`/bin/grep "prefix" /var/www/html/sites/default/settings.php | /bin/grep "=>" | /usr/bin/tail -1 | /usr/bin/awk -F"'" '{print $4}'`"
    
    if ( [ "${dbprefix}" = "" ] )
    then
        dbprefix="`/bin/grep "prefix" /var/www/html/sites/default/settings.php | /bin/grep "=>" | /usr/bin/tail -1 | /usr/bin/awk -F"\\"" '{print $4}'`"
    fi

    if ( [ -f /var/www/html/dbp.dat ] )
    then
        if ( [ "${dbprefix}" != "`/bin/cat /var/www/html/dbp.dat`" ] )
        then
            /bin/echo ${dbprefix} > /var/www/html/dbp.dat
        fi
    elif ( [ "${dbprefix}" != "" ] )
    then
         /bin/echo ${dbprefix} > /var/www/html/dbp.dat
    fi
    
    /bin/chown www-data:www-data /var/www/html/dbp.dat
    /bin/chmod 600 /var/www/html/dbp.dat

    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
    then
        /bin/echo "For your information this application requires Maria DB as its database" > /var/www/html/dbe.dat
    fi
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        /bin/echo "For your information this application requires MySQL as its database" > /var/www/html/dbe.dat
    fi

    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        /bin/echo "For your information this application requires Postgres as its database" > /var/www/html/dbe.dat
    fi

fi

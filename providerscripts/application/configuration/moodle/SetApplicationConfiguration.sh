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

if ( [ -f /var/www/html/moodle/config.php ] )
then
        /bin/chown www-data:www-data /var/www/html/moodle/config.php
        /bin/chmod 400 /var/www/html/moodle/config.php
fi

if ( [ -f ${HOME}/runtime/moodle_config.php ] )
then
        /bin/chown www-data:www-data ${HOME}/runtime/moodle_config.php
        /bin/chmod 400 ${HOME}/runtime/moodle_config.php
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
        exit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh moodle_config.php`" -lt "130" ] )
then
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh moodle_config.php ${HOME}/runtime/moodle_config.php
        if ( [ ! -f /var/www/html/moodle/config.php ] || [ "`/usr/bin/diff /var/www/html/moodle/config.php ${HOME}/runtime/moodle_config.php`" != "" ] )
        then
                /usr/bin/php -ln ${HOME}/runtime/moodle_config.php
                if ( [ "$?" = "0" ] )
                then
                        /bin/cp ${HOME}/runtime/moodle_config.php /var/www/html/moodle/config.php
                        /bin/chmod 600 /var/www/html/moodle/config.php
                        /bin/chown www-data:www-data /var/www/html/moodle/config.php
                        /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
                fi
        fi
fi

exit

diff=""
if ( [ -f /var/www/html/moodle/config.php ] && [ -f ${HOME}/runtime/moodle_config.php ] )
then
        diff="`/usr/bin/diff /var/www/html/moodle/config.php ${HOME}/runtime/moodle_config.php`"
fi

if ( ( [ ! -f ${HOME}/runtime/INITIAL_CONFIG_SET ] || [ "${diff}" != "" ] || [ ! -f ${HOME}/runtime/moodle_config.php ] ) && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh moodle_config.php`" != "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh moodle_config.php ${HOME}/runtime/moodle_config.php
        if ( [ ! -f /var/www/html/moodle/config.php ] || [ "`/usr/bin/diff /var/www/html/moodle/config.php ${HOME}/runtime/moodle_config.php`" != "" ] )
        then
                /usr/bin/php -ln ${HOME}/runtime/moodle_config.php
                if ( [ "$?" = "0" ] )
                then
                        /bin/cp ${HOME}/runtime/moodle_config.php  /var/www/html/moodle/config.php
                        /bin/chown www-data:www-data /var/www/html/moodle/config.php
                        /bin/chmod 600 /var/www/html/moodle/config.php
                        /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
                fi
        fi
fi
 

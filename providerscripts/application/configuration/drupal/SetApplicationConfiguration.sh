#!/bin/sh
####################################################################################
# Description: This script will update update the configration for drupal
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
set -x

if ( [ -f /var/www/html/sites/default/settings.php ] )
then
        /bin/chown www-data:www-data /var/www/html/sites/default/settings.php
        /bin/chmod 400 /var/www/html/sites/default/settings.php
fi

if ( [ -f ${HOME}/runtime/drupal_settings.php ] )
then
        /bin/chown www-data:www-data ${HOME}/runtime/drupal_settings.php
        /bin/chmod 400 ${HOME}/runtime/drupal_settings.php
fi


if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
        exit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh drupal_settings.php`" -lt "130" ] )
then
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh drupal_settings.php ${HOME}/runtime/drupal_settings.php
        if ( [ ! -f /var/www/html/sites/default/settings.php ] || [ "`/usr/bin/diff /var/www/html/sites/default/settings.php ${HOME}/runtime/drupal_settings.php`" != "" ] )
        then
                /usr/bin/php -ln ${HOME}/runtime/drupal_settings.php
                if ( [ "$?" = "0" ] )
                then
                        /bin/cp ${HOME}/runtime/drupal_settings.php /var/www/html/sites/default/settings.php
                        /bin/chmod 600 /var/www/html/sites/default/settings.php
                        /bin/chown www-data:www-data /var/www/html/sites/default/settings.php
                        /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
                fi
        fi
fi

diff=""
if ( [ -f /var/www/html/sites/default/settings.php ] && [ -f ${HOME}/runtime/drupal_settings.php ] )
then
        diff="`/usr/bin/diff /var/www/html/sites/default/settings.php  ${HOME}/runtime/drupal_settings.php`"
fi

if ( ( [ ! -f ${HOME}/runtime/INITIAL_CONFIG_SET ] || [ "${diff}" != "" ] || [ ! -f ${HOME}/runtime/drupal_settings.php ] ) && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh drupal_settings.php`" != "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh drupal_settings.php  ${HOME}/runtime/drupal_settings.php
        if ( [ ! -f /var/www/html/sites/default/settings.php ] || [ "`/usr/bin/diff /var/www/html/sites/default/settings.php  ${HOME}/runtime/drupal_settings.php`" != "" ] )
        then
                /usr/bin/php -ln  ${HOME}/runtime/drupal_settings.php
                if ( [ "$?" = "0" ] )
                then
                        /bin/cp  ${HOME}/runtime/drupal_settings.php  /var/www/html/sites/default/settings.php
                        /bin/chown www-data:www-data /var/www/html/sites/default/settings.php
                        /bin/chmod 600 /var/www/html/sites/default/settings.php
                        /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
                fi
        fi
fi

exit

diff="`/usr/bin/diff /var/www/html/sites/default/settings.php ${HOME}/runtime/drupal_settings.php`"

if ( ( [ ! -f ${HOME}/runtime/INITIAL_CONFIG_SET ] || [ "${diff}" != "" ] ) && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh drupal_settings.php`" != "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh drupal_settings.php ${HOME}/runtime/drupal_settings.php
        if ( [ "`/usr/bin/diff /var/www/html/sites/default/settings.php ${HOME}/runtime/drupal_settings.php`" != "" ] )
        then
                /usr/bin/php -ln ${HOME}/runtime/drupal_settings.php
                if ( [ "$?" = "0" ] )
                then
                        /bin/cp ${HOME}/runtime/drupal_settings.php  /var/www/html/sites/default/settings.php
                        /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
                fi
        fi
fi


#!/bin/sh
#######################################################################################
# Description: This script will install a drupal configuration. There creates a default
# configuration to bundled with the sourcecode which is used and customised for the
# particular deployment each time.
# Author: Peter Winter
# Date: 04/01/2017
########################################################################################
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
####################################################################################
####################################################################################
#set -x

if ( [ -f /var/www/html/sites/default/settings.php ] )
then
    /bin/chown www-data:www-data /var/www/html/sites/default/settings.php
    /bin/chmod 600 /var/www/html/sites/default/settings.php
fi

if ( [ ! -f /var/www/html/sites/default/settings.php ] )
then
    /bin/cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php
    /bin/chown www-data:www-data /var/www/html/sites/default/settings.php
    /bin/chmod 600 /var/www/html/sites/default/settings.php
fi

if ( [ ! -f /var/www/html/.htaccess ] || [ "`/bin/grep "Most of the following PHP settings cannot be changed at runtime" /var/www/html/.htaccess`" = "" ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/drupal-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data:www-data /var/www/html/.htaccess
    /bin/chmod 600 /var/www/html/.htaccess
fi

if ( [ ! -d /var/www/html/sites/default/files/private ] )
then
    /bin/mkdir -p /var/www/html/sites/default/files/private
    /bin/chown -R www-data:www-data /var/www/html/sites/default/files
    /usr/bin/find /var/www/html/sites/default/files -type d -exec chmod g+ws {} \;
    /usr/bin/find /var/www/html/sites/default/files -type f -exec chmod 664 {} \;

else
    /bin/chown -R www-data:www-data /var/www/html/sites/default/files
    /usr/bin/find /var/www/html/sites/default/files -type d -exec chmod g+ws {} \;
    /usr/bin/find /var/www/html/sites/default/files -type f -exec chmod 664 {} \;
fi

if ( [ ! -f /var/www/html/sites/default/files/private/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/drupal-htaccess-private.txt /var/www/html/sites/default/files/private/.htaccess
    /bin/chown www-data:www-data /var/www/html/sites/default/files/private/.htaccess
    /bin/chmod 600 /var/www/html/sites/default/files/private/.htaccess
fi

/bin/echo "1"

#!/bin/sh
#######################################################################################
# Description: This script will create any required directories for a successful
# drupal install
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
	/bin/cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php.default
	/bin/chown www-data:www-data /var/www/html/sites/default/settings.php.default
	/bin/chmod 600 /var/www/html/sites/default/settings.php.default
fi

#if ( [ -f /var/www/html/.htaccess ] && [ ! -f /var/www/html/.htaccess.orig ] )
#then
#	/bin/cp /var/www/html/.htaccess /var/www/html/.htaccess.orig
# 	/bin/chmod 600 /var/www/html/.htaccess.orig
#  	/bin/chown www-data:www-data /var/www/html/.htaccess.orig
#fi

#if ( [ ! -f /var/www/html/.htaccess ] || [ "`/bin/grep "Most of the following PHP settings cannot be changed at runtime" /var/www/html/.htaccess`" = "" ] )
#then
#	/bin/cp ${HOME}/application/configuration/drupal-htaccess.txt /var/www/html/.htaccess
#	/bin/chown www-data:www-data /var/www/html/.htaccess
#	/bin/chmod 600 /var/www/html/.htaccess
#fi

if ( [ ! -d /var/www/private/default_images ] )
then
	/bin/mkdir -p /var/www/private/default_images
	/bin/chown -R www-data:www-data /var/www/private
	/usr/bin/find /var/www/private -type d -exec chmod 755 {} \;
	/usr/bin/find /var/www/private -type f -exec chmod 644 {} \;
fi

if ( [ ! -f /var/www/private/styles/social_medium/private/default_images/default-profile-picture.png.webp ] )
then
	/bin/cp -r /var/www/html/sites/default/files/private/* /var/www/private
	/usr/bin/find /var/www -path /var/www/html -prune -o -exec /bin/chown www-data:www-data {} +
fi

#This is the php temporary upload directory
if ( [ ! -d /var/www/html/tmp ] )
then
	/bin/mkdir -p /var/www/html/tmp
	/bin/chown www-data:www-data /var/www/html/tmp
	/bin/chmod 755 /var/www/html/tmp
fi

if ( [ ! -d /var/www/tmp ] )
then
	/bin/mkdir -p /var/www/tmp
	/bin/chmod 755 /var/www/tmp
	/bin/chown www-data:www-data /var/www/tmp
fi

/bin/echo "1"

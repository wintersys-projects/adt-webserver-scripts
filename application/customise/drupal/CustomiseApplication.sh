#!/bin/sh
###########################################################################################################
# Description: Apply any customisations you want to make to drupal
# Author : Peter Winter
# Date: 17/05/2017
######################################################################################################
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
#set-x

if ( [ ! -d /var/www/html/tmp ] )
then
	/bin/mkdir /var/www/html/tmp
	/bin/chmod 755 /var/www/html/tmp
	/bin/chown www-data:www-data /var/www/html/tmp
fi

if ( [ ! -d /var/www/html/logs ] )
then
	/bin/mkdir /var/www/html/logs
	/bin/chmod 755 /var/www/html/logs
	/bin/chown www-data:www-data /var/www/html/logs
fi

if ( [ ! -d /var/www/html/cache ] )
then
	/bin/mkdir /var/www/html/cache
	/bin/chmod 755 /var/www/html/cache
	/bin/chown www-data:www-data /var/www/html/cache
fi

if ( [ "`/bin/cat /var/www/html/dbt.dat`" = "SOCIAL_DRUPAL" ] || [ "`/bin/cat /var/www/html/dbt.dat`" = "CMS_DRUPAL" ] )
then
	if ( [ -d /var/www/html/vendor ] )
	then
		/bin/mv /var/www/html/vendor /var/www/vendor
		/bin/chown -R www-data:www-data /var/www/vendor
		/usr/bin/find /var/www/vendor -type d -print -exec chmod 755 {} \;
		/usr/bin/find /var/www/vendor -type f -print -exec chmod 644 {} \;
	fi

	if ( [ -d /var/www/html/recipes ] )
	then
		/bin/mv /var/www/html/recipes /var/www/recipes
		/bin/chown -R www-data:www-data /var/www/recipes
		/usr/bin/find /var/www/recipes -type d -print -exec chmod 755 {} \;
		/usr/bin/find /var/www/recipes -type f -print -exec chmod 644 {} \;
	fi
fi

if ( [ -d /var/www/html/private ] )
then
	if ( [ ! -d  /var/www/private/default_images ] )
	then
		/bin/mkdir -p /var/www/private/default_images
	fi

	/bin/mv /var/www/html/private/* /var/www/private
	/bin/rm -r /var/www/html/private
	/bin/chown -R www-data:www-data /var/www/private

	if ( [ -f /var/www/private/styles/social_medium/private/default_images/default-profile-picture.png.webp ] )
	then
		/bin/cp -r /var/www/html/sites/default/files/private/* /var/www/private
	fi

	/usr/bin/find /var/www/private -type d -print -exec chmod 755 {} \;
	/usr/bin/find /var/www/private -type f -print -exec chmod 644 {} \;
fi


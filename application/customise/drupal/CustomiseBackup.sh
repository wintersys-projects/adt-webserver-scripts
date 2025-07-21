#!/bin/sh
###########################################################################################################
# Description: Customise the backup if you need to specific to drupal
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
#########################################################################################
#########################################################################################
#set -x

identifier="${1}"

if ( [ "${identifier}" != "" ] )
then
	if ( [ -d ${HOME}/backups/${identifier} ] )
	then
		if ( [ -f ${HOME}/backups/${identifier}/sites/default/settings.php ] )
		then
			/bin/rm ${HOME}/backups/${identifier}/sites/default/settings.php
		fi
	fi
	if ( [ -d ${idenfitier} ] )
	then
		if ( [ -f ${identifier}/sites/default/settings.php ] )
		then
			/bin/rm ${identifier}/sites/default/settings.php
		fi
	fi
else
	if ( [ -f /var/www/composer.json ] )
	then
		/bin/cp /var/www/composer.json /var/www/html/composer.json
	fi

	if ( [ -f /var/www/composer.lock ] )
	then
		/bin/cp /var/www/composer.lock /var/www/html/composer.lock
	fi

	if ( [ -d /var/www/private ] )
	then
		if ( [ -d /var/www/html/private ] )
		then
			/bin/rm -r /var/www/html/private/*
		else
			/bin/mkdir /var/www/html/private
		fi
		/bin/cp -r /var/www/private/* /var/www/html/private
		/bin/chown -R www-data:www-data /var/www/html/private
	fi

	if ( [ "`/bin/cat /var/www/html/dbt.dat`" = "SOCIAL_DRUPAL" ] || [ "`/bin/cat /var/www/html/dbt.dat`" = "CMS_DRUPAL" ] )
	then
		if ( [ -d /var/www/recipes ] )
		then
			if ( [ -d /var/www/html/recipes ] )
			then
				/bin/rm -r /var/www/html/recipes/*
			else
				/bin/mkdir /var/www/html/recipes
			fi
			/bin/cp -r /var/www/recipes/* /var/www/html/recipes
			/bin/chown -R www-data:www-data /var/www/html/recipes
		fi

		if ( [ -d /var/www/vendor ] )
		then
			if ( [ -d /var/www/html/vendor ] )
			then
				/bin/rm -r /var/www/html/vendor/*
			else
				/bin/mkdir /var/www/html/vendor 
			fi
			/bin/cp -r /var/www/vendor/* /var/www/html/vendor 
			/bin/chown -R www-data:www-data /var/www/html/vendor
		fi
	fi
fi






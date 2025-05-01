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

baseline_name="${1}"

if ( [ "${baseline_name}" != "" ] )
then
	if ( [ -f ${HOME}/backups/${baseline_name}/sites/default/settings.php ] )
	then
		/bin/rm ${HOME}/backups/${baseline_name}/sites/default/settings.php
	fi
else
	if ( [ -d /var/www/private ] )
	then
		if ( [ -d /var/www/html/private ] )
		then
        		/bin/rm -r /var/www/html/private/*
		else
        		/bin/mkdir /var/www/html/private
		fi
        	/bin/cp -r /var/www/private/* /var/www/html/private
	fi

	if ( [ -d /var/www/recipes ] )
	then
		if ( [ -d /var/www/html/recipes ] )
		then
        		/bin/rm -r /var/www/html/recipes/*
		else
        		/bin/mkdir /var/www/html/recipes
		fi
        	/bin/cp -r /var/www/recipes/* /var/www/html/recipes
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
	fi
fi




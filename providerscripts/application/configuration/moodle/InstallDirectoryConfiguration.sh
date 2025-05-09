#!/bin/sh
#######################################################################################
# Description: This script will create any required directories for a successful
# moodle install
# Author: Peter Winter
# Date: 04/01/2017
#######################################################################################
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
#######################################################################################
#######################################################################################
#set -x
 
if ( [ -f /var/www/html/moodle/config.php ] )
then
	/bin/chown www-data:www-data /var/www/html/moodle/config.php
	/bin/chmod 600 /var/www/html/moodle/config.php
fi


if ( [ ! -f /var/www/html/moodle/config.php ] )
then
	if ( [ -f /var/www/html/moodle/config-dist.php ] )
	then
		/bin/cp /var/www/html/moodle/config-dist.php /var/www/html/moodle/config.php.default
		/bin/chown www-data:www-data /var/www/html/moodle/config.php.default
		/bin/chmod 600 /var/www/html/moodle/config.php.default
	fi
fi
	
if ( [ ! -f /var/www/html/.htaccess ] )
then
	/bin/cp ${HOME}/providerscripts/application/configuration/moodle-htaccess.txt /var/www/html/.htaccess
	/bin/chown www-data:www-data /var/www/html/.htaccess
	/bin/chmod 440 /var/www/html/.htaccess
fi
	
if ( [ -d /var/www/html/moodledata ] )
then
	if ( [ -d /var/www/moodledata ] )
	then
		/bin/rm -r /var/www/moodledata
	fi
	/bin/mv /var/www/html/moodledata /var/www/moodledata
else
	/bin/mkdir -p /var/www/moodledata/filedir
fi

#This is the php temporary upload directory
if ( [ ! -d /var/www/html/tmp ] )
then
	/bin/mkdir -p /var/www/html/tmp
	/bin/chmod 755 /var/www/html/tmp
	/bin/chown www-data:www-data /var/www/html/tmp
fi
	
/bin/echo "1"

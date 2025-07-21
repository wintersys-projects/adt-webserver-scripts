#!/bin/sh
################################################################################
# Description: This script will create any required directories for a successful
# wordpress install
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
##################################################################################
##################################################################################
#set -x

if ( [ -f /var/www/html/wp-config.php ] )
then
	/bin/chown www-data:www-data /var/www/html/wp-config.php
	/bin/chmod 600 /var/www/html/wp-config.php
fi

if ( [ ! -f /var/www/html/wp-config.php ] )
then
	if ( [ -f /var/www/html/wp-config-sample.php ] )
	then
		/bin/cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php.default
		/bin/chmod 600 /var/www/html/wp-config.php.default
		/bin/chown www-data:www-data /var/www/html/wp-config.php.default
	fi
fi

if ( [ ! -d /var/www/html/tmp ] )
then
	/bin/mkdir /var/www/html/tmp
	/bin/chmod -R 755 /var/www/html/tmp
	/bin/chown -R www-data:www-data /var/www/html/tmp
fi

if ( [ ! -d /var/www/html/wp-content/logs ] )
then
	/bin/mkdir /var/www/html/wp-content/logs
	/bin/chmod -R 755 /var/www/html/wp-content/logs
	/bin/chown -R www-data:www-data /var/www/html/wp-content/logs
fi

if ( [ ! -d /var/www/html/wp-content/cache ] )
then
	/bin/mkdir /var/www/html/wp-content/cache
	/bin/chmod -R 755 /var/www/html/wp-content/cache
	/bin/chown -R www-data:www-data /var/www/html/wp-content/cache
fi

BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
${HOME}/installscripts/InstallWPCLI.sh ${BUILDOS}

/bin/echo "1"

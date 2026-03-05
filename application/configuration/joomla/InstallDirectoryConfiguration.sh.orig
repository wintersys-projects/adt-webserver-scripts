#!/bin/sh
#######################################################################################
# Description: This script will create any required directories for a successful
# joomla install
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

if ( [ -f /var/www/html/configuration.php ] )
then
	/bin/chown www-data:www-data /var/www/html/configuration.php
	/bin/chmod 400 /var/www/html/configuration.php
fi

if ( [ ! -f /var/www/html/configuration.php ] )
then
	if ( [ -f /var/www/html/installation/configuration.php-dist ] )
	then
		/bin/cp /var/www/html/installation/configuration.php-dist /var/www/html/configuration.php.default
		/bin/chown www-data:www-data /var/www/html/configuration.php.default
		/bin/chmod 600 /var/www/html/configuration.php.default
	fi
fi

if ( [ ! -f /var/www/html/configuration.php ] && [ ! -d /var/www/html/installation ] )
then
	if ( [ -f /var/www/html/configuration.php.default ] )
	then
		/bin/cp /var/www/html/configuration.php.default /var/www/html/configuration.php
		/bin/chown www-data:www-data /var/www/html/configuration.php
		/bin/chmod 600 /var/www/html/configuration.php
	fi
fi

#if ( [ -f /var/www/html/.htaccess ] && [ ! -f /var/www/html/.htaccess.orig ] )
#then#
#	/bin/cp /var/www/html/.htaccess /var/www/html/.htaccess.orig
# 	/bin/chmod 600 /var/www/html/.htaccess.orig
#  	/bin/chown www-data:www-data /var/www/html/.htaccess.orig
#fi

#if ( [ ! -f /var/www/html/.htaccess ] || [ "`/bin/grep "Protect against certain cross-origin requests" /var/www/html/.htaccess`" = "" ] )
#then#
#	/bin/cp ${HOME}/application/configuration/joomla-htaccess.txt /var/www/html/.htaccess#
#	/bin/chown www-data:www-data /var/www/html/.htaccess
#	/bin/chmod 600 /var/www/html/.htaccess
#fi

#The temp directories for joomla can be set. They should exist already, but why the hell not make sure.
if ( [ ! -d /var/www/html/cache ] )
then
	/bin/mkdir -p /var/www/html/cache
	/bin/chown www-data:www-data /var/www/html/cache
	/bin/chmod 755 /var/www/html/cache
fi

if ( [ ! -d /var/www/html/administrator/cache ] )
then
	/bin/mkdir -p /var/www/html/administrator/cache
	/bin/chown www-data:www-data /var/www/html/administrator/cache
	/bin/chmod 755 /var/www/html/administrator/cache
fi


if ( [ ! -d /var/www/html/tmp ] )
then
	/bin/mkdir -p /var/www/html/tmp
	/bin/chown www-data:www-data /var/www/html/tmp
	/bin/chmod 755 /var/www/html/tmp
fi

if ( [ ! -d /var/www/html/logs ] )
then
	/bin/mkdir -p /var/www/html/logs
	/bin/chown www-data:www-data /var/www/html/logs
	/bin/chmod 755 /var/www/html/logs
fi

/bin/echo "1"


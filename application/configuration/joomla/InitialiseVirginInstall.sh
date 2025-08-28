#!/bin/sh
#############################################################################################
# Description: This script will initialise a virgin copy of joomla
# has been fully installed.
# Author: Peter Winter
# Date: 04/01/2017
#############################################################################################
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
##########################################################################################
##########################################################################################
#set -x

#This is how we tell ourselves this is a joomla application
/bin/echo "JOOMLA" > /var/www/html/dba.dat

while ( [ ! -f /var/www/html/installation/_J* ] )
do
        /bin/sleep 1
done

if ( [ -f /var/www/html/installation/_J* ] )
then
        /bin/rm /var/www/html/installation/_J*
fi

#Once the marker file has been removed and the installation initiated by the user, the configuration file will be generated
while ( [ ! -f /var/www/html/configuration.php ] )
do
	/bin/sleep 1
done

# We nneed our database prefix because that will be what is used in the database dump
while ( [ ! -f /var/www/html/dbp.dat ] || [ "`/bin/cat /var/www/html/dbp.dat`" = "" ] )
do
	dbprefix="`/bin/grep "dbprefix" /var/www/html/configuration.php | /usr/bin/awk -F"'" '{print $2}'`"

	if ( [ "${dbprefix}" = "" ] )
	then
		dbprefix="`/bin/grep "dbprefix" /var/www/html/configuration.php | /usr/bin/awk -F'"' '{print $2}'`"
	fi
	/bin/echo ${dbprefix} > /var/www/html/dbp.dat
	/bin/chown www-data:www-data /var/www/html/dbp.dat
	/bin/chmod 600 /var/www/html/dbp.dat
done

if ( [ -f ${HOME}/runtime/overridehtaccess/htaccess.conf ] )
then
	/bin/cp ${HOME}/runtime/overridehtaccess/htaccess.conf /var/www/html/.htaccess 
	/bin/chmod 444 /var/www/html/.htaccess
	/bin/chown www-data:www-data /var/www/html/.htaccess
fi

#For ease of use we tell ourselves what database engine this webroot is associated with
if ( [ ! -f /var/www/html/dbe.dat ] || [ "`/bin/cat /var/www/html/dbe.dat`" = "" ] )
then
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
	then
		/bin/echo "For your information this application requires Maria DB as its database" > /var/www/html/dbe.dat
	fi

	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
	then
		/bin/echo "For your information this application requires MySQL as its database" > /var/www/html/dbe.dat
	fi

	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
	then
		/bin/echo "For your information this application requires Postgres as its database" > /var/www/html/dbe.dat
	fi

	if ( [ -f /var/www/html/dbe.dat ] )
	then
		/bin/chown www-data:www-data /var/www/html/dbe.dat
		/bin/chmod 600 /var/www/html/dbe.dat
	fi
fi


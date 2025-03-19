#!/bin/sh
#############################################################################################
# Description: If your application requires any post processing to be performed,
# then, this is the place to put it. Post processing is considered to be any processing
# which is required after the application is considered installed. This is the post
# processing for a joomla install. If you examine the code, you will find that this
# script is called from the build machine over ssh once it considers that the application
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

if ( [ ! -f /var/www/html/dbp.dat ] && [ -f /var/www/html/configuration.php ] )
then
        dbprefix="`/bin/grep "dbprefix" /var/www/html/configuration.php | /usr/bin/awk -F"'" '{print $2}'`"

        if ( [ "${dbprefix}" = "" ] )
        then
                dbprefix="`/bin/grep "dbprefix" /var/www/html/configuration.php | /usr/bin/awk -F'"' '{print $2}'`"
        fi

        /bin/echo ${dbprefix} > /var/www/html/dbp.dat
        /bin/chown www-data:www-data /var/www/html/dbp.dat
        /bin/chmod 600 /var/www/html/dbp.dat
fi

if ( [ ! -f /var/www/html/dbe.dat ] && [ -f /var/www/html/configuration.php ] )
then
        if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
        then
                /bin/echo "For your information this application requires Maria DB as its database" > /var/www/html/dbe.dat
        fi

        if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
        then
                /bin/echo "For your information this application requires MySQL as its database" > /var/www/html/dbe.dat
        fi

        if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
        then
                /bin/echo "For your information this application requires Postgres as its database" > /var/www/html/dbe.dat
        fi
fi

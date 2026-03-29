#!/bin/sh
#############################################################################
# Description: This script will check if a webserver is alive and responsive
# on an application basis.
# Date: 16-11-2016
# Author: Peter Winter
############################################################################
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
############################################################################
############################################################################
#set -x

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:None`" = "1" ] )
then
	/bin/echo "ALIVE"
	exit
fi

config_file="`/bin/grep "^CONFIG_FILE:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${config_file}" = "" ] )
then
        config_file="/var/www/html/configuration.php"
fi

DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

if ( [ "`/bin/grep -- "${DB_N}" ${config_file}`" = "" ] || [ "`/bin/grep -- "${DB_P}" ${config_file}`" = "" ] || [ "`/bin/grep -- "${DB_U}" ${config_file}`" = "" ] )
then
	exit
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] )
then
	${HOME}/utilities/status/CheckServerAlive.sh
else
	/bin/echo "ALIVE"
fi


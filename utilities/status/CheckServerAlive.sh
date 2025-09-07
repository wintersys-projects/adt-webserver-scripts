#!/bin/sh
####################################################################################
# Description: This script checks to see if the server is alive. It's a simple process,
# it connects to the database and checks that a response is returned. This way, we know
# that we are alive and well.
# Date: 16/11/2016
# Author: Peter Winter
###################################################################################
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
#set -x

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:None`" = "1" ] )
then
	/bin/echo "ALIVE"
else
	DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
	DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
 
	if ( [ "`/bin/echo ${DB_U} | /bin/grep ':::'`" != "" ] )
 	then
  		DB_U="`/bin/echo ${DB_U} | /usr/bin/awk -F':::' '{print $NF}'`"
	fi
	if ( [ "`/bin/echo ${DB_P} | /bin/grep ':::'`" != "" ] )
 	then
  		DB_P="`/bin/echo ${DB_P} | /usr/bin/awk -F':::' '{print $NF}'`"
	fi
 
	DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"
	DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"
	SERVER_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"

	if ( [ "${SERVER_NAME}" = "self-managed" ] )
	then
		SERVER_NAME="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/* | /usr/bin/head -1`"
		${HOME}/utilities/config/StoreConfigValue.sh "DBIDENTIFIER" "${SERVER_NAME}"
	fi

	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASE_DBaaS_INSTALLATION_TYPE:Maria`" = "1" ] ||  [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASE_DBaaS_INSTALLATION_TYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
	then
		if ( [ -f /usr/bin/php ] && ( [ "`/usr/bin/php ${HOME}/utilities/remote/mysqlalive.php ${SERVER_NAME} ${DB_U} ${DB_P} ${DB_N} ${DB_PORT} | /bin/sed 's/ //g'`" = "ALIVE" ] ) )
		then
			/bin/echo "ALIVE"
		fi
	fi

	if ( [ -f /usr/bin/php ] && ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASE_DBaaS_INSTALLATION_TYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] ) )
	then
		if ( [ "`/usr/bin/php ${HOME}/utilities/remote/postgresalive.php ${SERVER_NAME} ${DB_U} ${DB_P} ${DB_N} ${DB_PORT} | /bin/sed 's/ //g'`" = "ALIVE" ] )
		then
			/bin/echo "ALIVE"
		fi
	fi
fi



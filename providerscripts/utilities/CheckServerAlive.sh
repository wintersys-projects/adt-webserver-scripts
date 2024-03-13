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

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:None`" = "1" ] )
then
    /bin/echo "ALIVE"
else
    
    DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
    DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
    DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
    then
        SERVER_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
    else
        SERVER_NAME="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/* | /usr/bin/head -1`"
    fi

    DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        if ( [ -f /usr/bin/php ] && ( [ "`/usr/bin/php ${HOME}/providerscripts/utilities/dbalive/mysqlalive.php ${SERVER_NAME} ${DB_U} ${DB_P} ${DB_N} ${DB_PORT} | /bin/sed 's/ //g'`" = "ALIVE" ] ) )
        then
            /bin/echo "ALIVE"
        fi
    fi

    if ( [ -f /usr/bin/php ] && ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] ) )
    then
        if ( [ "`/usr/bin/php ${HOME}/providerscripts/utilities/dbalive/postgresalive.php ${SERVER_NAME} ${DB_U} ${DB_P} ${DB_N} ${DB_PORT} | /bin/sed 's/ //g'`" = "ALIVE" ] )
        then
            /bin/echo "ALIVE"
        fi
    fi
fi


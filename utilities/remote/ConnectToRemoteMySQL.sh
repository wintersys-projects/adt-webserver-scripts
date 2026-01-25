#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/06/2021
# Description: Connect to the remote MySQL or MariaDB database and execute a query if 
# present. It uses the provided credentials that are part of the build process.
#####################################################################################
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

if ( [ "`/usr/bin/hostname | /bin/grep "\-rp-"`" != "" ] || [ "`/usr/bin/hostname | /bin/grep "\-auth-"`" != "" ] )
then
        /bin/echo "Can't connect to dstabase from this machine type"
fi

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

if ( [ -f /usr/bin/mariadb ] )
then
        mysql="/usr/bin/mariadb"
else
        mysql="/usr/bin/mysql"
fi

num_args="$#"
count="1"
sql_command=""

while ( [ "{num_args}" != "0" ] && [ "${count}" -le "${num_args}" ] )
do
        sql_command="${sql_command} ${1}"
        count="`/usr/bin/expr ${count} + 1`"
        shift 
done

DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"

if ( [ "`/bin/echo ${DB_U} | /bin/grep ':::'`" != "" ] )
then
        DB_U="`/bin/echo ${DB_U} | /usr/bin/awk -F':::' '{print $1}'`"
fi
if ( [ "`/bin/echo ${DB_P} | /bin/grep ':::'`" != "" ] )
then
        DB_P="`/bin/echo ${DB_P} | /usr/bin/awk -F':::' '{print $1}'`"
fi

DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"


if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
        HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
        HOST="`${HOME}/providerscripts/datastore/dedicated/ListFromDatastore.sh "config" "databaseip/*"`"
        HOST2="`${HOME}/providerscripts/datastore/dedicated/ListFromDatastore.sh "config" "databasepublicip/*"`"
fi

DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

if ( [ "${sql_command}" != "" ]  )
then
        ${mysql} --silent --raw -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e "${sql_command}"
else
        ${mysql} -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}"
fi


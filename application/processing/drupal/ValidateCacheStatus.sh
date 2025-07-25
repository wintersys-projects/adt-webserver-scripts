#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/06/2021
# Description: This will truncate the cache tables if a specific error arises which 
# tells us the cache is inconsistent. I don't know enough about DRUPAL to be able to 
# know why but sometimes the cache gets inconsistent and the way that is sorted out is
# by truncating the caching tables in the database. I monitor for inconsistent cache
# statuses on a minute by minute basis from cron whenever a drupal based application is
# installed.
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

if ( [ "`/usr/bin/curl --insecure https://localhost:443 | /bin/grep 'No route found for'`" != "" ] )
then
        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] ||  [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] ||  [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] ||  [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ]  )
        then
                prefix="`/bin/cat /var/www/html/dbp.dat`"
                cache_tables="` ${HOME}/utilities/remote/ConnectToRemoteMySQL.sh " select table_schema as database_name, table_name from information_schema.tables where table_type = 'BASE TABLE' and table_name like '${prefix}%cache%' order by table_schema, table_name;" | /bin/grep -v 'database_' | /bin/grep -v 'table_' | /usr/bin/awk '{print $NF}'`"

                success="yes"

                for cache_table in ${cache_tables}
                do
                        ${HOME}/utilities/remote/ConnectToRemoteMySQL.sh "TRUNCATE ${cache_table};" > /dev/null 2>&1

                        if ( [ "$?" != "0" ] )
                        then
                                success="no"
                        fi
                done

                if ( [ "${success}" = "yes" ] )
                then
                        /bin/echo "TRUNCATED"
                else
                        /bin/echo "NOT TRUNCATED"
                fi
        fi

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] ||  [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ]  )
        then
                prefix="`/bin/cat /var/www/html/dbp.dat`"
                cache_tables="` ${HOME}/utilities/remote/ConnectToRemotePostgres.sh "select table_schema, table_name from information_schema.tables where table_name like '%cache%' and table_schema not in ('information_schema', 'pg_catalog') and table_type = 'BASE TABLE' order by table_name, table_schema;" | sed -n '/cache/s/.*\b\(.*cache\w*\).*/\1/p'`"
                success="yes"

                for cache_table in ${cache_tables}
                do
                        ${HOME}/utilities/remote/ConnectToRemotePostgres.sh "TRUNCATE ${cache_table};" > /dev/null 2>&1

                        if ( [ "$?" != "0" ] )
                        then
                                success="no"
                        fi
                done

                if ( [ "${success}" = "yes" ] )
                then
                        /bin/echo "TRUNCATED"
                else
                        /bin/echo "NOT TRUNCATED"
                fi
        fi
fi

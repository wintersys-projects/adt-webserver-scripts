#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/07/2016
# Description: This is a simple way of checking that drupal has installed correctly. 
# The way I check is just to check if any users have been added to the _users table. 
# If users exist, then, we can assume that the install has been completed. 
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

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] ||  [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ]  )
then
	prefix="`/bin/cat /var/www/html/dbp.dat`"
	installed="`${HOME}/utilities/remote/ConnectToRemoteMySQL.sh "SELECT * from ${prefix}users" | /bin/sed 's/ //g' | /bin/sed '/^$/d' | /usr/bin/wc -l`"

	if ( [ "${installed}" != "0" ] && [ "${installed}" != "" ] )
	then
		/bin/echo "INSTALLED"
	else
		/bin/echo "NOT INSTALLED"
	fi
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
	prefix="`/bin/cat /var/www/html/dbp.dat`"
	installed="`${HOME}/utilities/remote/ConnectToRemotePostgres.sh "select * from ${prefix}users;" | /bin/sed 's/ //g' | /bin/sed '/^$/d' | /usr/bin/wc -l`"

	if ( [ "${installed}" != "0" ] && [ "${installed}" != "" ]  )
	then
		/bin/echo "INSTALLED"
	else
		/bin/echo "NOT INSTALLED"
	fi
fi

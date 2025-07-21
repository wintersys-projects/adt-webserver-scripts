#!/bin/sh
############################################################################################################
# Description: This script will backup your webroot to your datastore and these backups are then used
# to make installations during future deployments. We only want one webserver to be authoritative when it comes
# to making the backup, so, we sleep for an arbitrary time and then attempt to get a shared lock file. If the
# lock file exists it means another webserver is authoritative for this backup cycle and we exit. If there is
# no shared lock file, we create one and proceed with making the backup ourselves because this webserver has  
# become authoritative. We sleep before we remove the lockfile because otherwise a backup might complete
# and remove the lockfile before another webserver tests to see if there is a lockfile and then we would get 
# a second backup process running
# Date: 16/11/2016
# Author: Peter Winter
###########################################################################################################
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

periodicity="${1}"

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh BACKUP_RUNNING`" != "" ] )
then
	if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh BACKUP_RUNNING`" -gt "300" ] )
	then
		${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh BACKUP_RUNNING
	fi
fi

/bin/sleep "`/usr/bin/shuf -i1-60 -n1`"

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh BACKUP_RUNNING`" != "" ] )
then
	exit
else
	${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh BACKUP_RUNNING
fi

${HOME}/application/backupscripts/Backup.sh "${periodicity}"

/bin/sleep 300

${HOME}/providerscripts/datastore/configwrapper/DeletetFromConfigDatastore.sh BACKUP_RUNNING


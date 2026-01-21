#!/bin/sh
################################################################################################
# Author: Peter Winter
# Date  : 9/4/2016
# Description : Shutdown this websever, all shutdowns should come through here so that any 
# cleanup that is needed can be put here. A backup of the webroot is made here with the special
# periodicity of "shutdown" so that we have a backup to reference of how the system was immediately
# prior to shutdown
################################################################################################
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
#################################################################################################
#################################################################################################
#set -x

HOME="`/bin/cat /home/homedir.dat`"

/bin/touch ${HOME}/runtime/SHUTDOWN-INITIATED

/bin/echo ""
/bin/echo "###########################################################################################"
/bin/echo "Shutting down a webserver with `${HOME}/utilities/processing/GetPublicIP.sh`, please wait whilst I clean the place up first"
/bin/echo "###########################################################################################"
/bin/echo ""

if ( [ "`${HOME}/providerscripts/datastore/config/wrapper/ListFromConfigDatastore.sh BACKUP_RUNNING`" != "" ] )
then
	if ( [ "`${HOME}/providerscripts/datastore/config/wrapper/AgeOfConfigFile.sh BACKUP_RUNNING`" -gt "300" ] )
	then
		${HOME}/providerscripts/datastore/config/wrapper/DeleteFromConfigDatastore.sh BACKUP_RUNNING "yes" "no"
	fi
fi

/bin/sleep "`/usr/bin/shuf -i1-30 -n1`"

if ( [ "`${HOME}/providerscripts/datastore/config/wrapper/ListFromConfigDatastore.sh BACKUP_RUNNING`" = "" ] )
then
	${HOME}/providerscripts/datastore/config/wrapper/PutToConfigDatastore.sh BACKUP_RUNNING "root" "no"
fi 

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

if ( [ "${MULTI_REGION}" = "1" ] )
then
	public_ip="`${HOME}/utilities/processing/GetPublicIP.sh`"
	multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
	${HOME}/providerscripts/datastore/dedicated/DeleteFromDatastore.sh ${multi_region_bucket}/dbaas_ips/${public_ip}
fi

${HOME}/application/backupscripts/Backup.sh "shutdown"

${HOME}/providerscripts/datastore/config/wrapper/DeleteFromConfigDatastore.sh BACKUP_RUNNING "yes" "no"


# Put any shutdown processing that you need here

if ( [ "${1}" = "halt" ] )
then
	/usr/sbin/shutdown -h now
elif ( [ "${1}" = "reboot" ] )
then
	/usr/sbin/shutdown -r now
fi


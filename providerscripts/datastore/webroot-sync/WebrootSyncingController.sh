#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This script is the controller of our webroot syncing process.
# There's three core phases
# 1. If historical webroot updates from other machines need to be applied they are applied
# this will be the case for newly provisioned machines and machines that have been rebooted
# (and possibly missed updates whilst offline)
# 2. Any changes to the current server's webroot are pushed out to the datastore so that
# other webservers can use those changes to update themselves to be up to date with us.
# 3. Any changes to other servers in our webserver fleet are obtained from the datastore
# and we apply to ourselves to keep ourselves up to date with them
# 4. Housekeeping - clean up any expired achives and so on. 
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
####################################################################################
####################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/datastore/config/toolkit/ListFromConfigDatastore.sh INSTALLED_SUCCESSFULLY`" = "" ] )
then
	exit
fi

historical="0"
if ( [ "`/bin/ls ${HOME}/runtime/webroot_sync/PREVIOUSEXECUTIONTIME:*`" = "" ] )
then
	#We want to process historically if this is our first time (for example we are a brand new webserver booting up after a scaling event)
	historical="1"
else
	#if a webserver is offline for a while it might miss some updates so process historically
	previous="`/bin/ls ${HOME}/runtime/webroot_sync/PREVIOUSEXECUTIONTIME:* | /usr/bin/awk -F':' '{print $NF}'`"
	current="`/usr/bin/date +%s`"
	time_since_last_run="`/usr/bin/expr ${current} - ${previous}`"

	if ( [ "${time_since_last_run}" -gt "60" ] )
	then
		historical="1"
	fi
	/bin/rm ${HOME}/runtime/webroot_sync/PREVIOUSEXECUTIONTIME:*
fi
	
/bin/touch ${HOME}/runtime/webroot_sync/PREVIOUSEXECUTIONTIME:`/usr/bin/date +%s`

#If a process has been running for a long time we don't want it blocking us
pids="`/bin/ps -A -o pid,cmd | /bin/grep "/webroot-sync/" | /bin/grep -v grep | /usr/bin/awk '{print $1}'`"
for pid in ${pids}
do
        minutes="`/bin/ps -o etime -p ${pid} | /usr/bin/tail -n +2 | /usr/bin/awk -F':' '{print $1}'`"
		if ( [ "${minutes}" != "" ] )
		then
        	if ( [ ${minutes} -gt 5 ] )
        	then
            	/usr/bin/kill -TERM ${pid}
        	fi
		fi
done

execution_order="${1}"

if ( [ "`/bin/ls ${HOME}/runtime/webroot_sync/DISABLE_EXECUTION:${execution_order} 2>/dev/null`" != "" ] )
then
        /usr/bin/find  ${HOME}/runtime/webroot_sync/DISABLE_EXECUTION:${execution_order} -type f -mmin +5 -delete
fi

if ( [ "`/bin/ls ${HOME}/runtime/webroot_sync/DISABLE_EXECUTION:* 2>/dev/null`" != "" ] )
then
	exit
else
	/bin/touch ${HOME}/runtime/webroot_sync/DISABLE_EXECUTION:${execution_order}
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/outgoing/additions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/outgoing/additions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/outgoing/deletions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/outgoing/deletions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming/additions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming/additions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming/deletions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming/deletions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming/additions/processed ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming/additions/processed
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming/deletions/processed ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming/deletions/processed
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/historical/incoming/additions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/historical/incoming/additions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/historical/incoming/deletions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/historical/incoming/deletions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/audit ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/audit
fi

if ( [ "${historical}" = "1" ] )
then
	${HOME}/providerscripts/datastore/webroot-sync/ProcessIncomingHistoricalWebrootUpdates.sh
else
	${HOME}/providerscripts/datastore/webroot-sync/ProcessOutgoingWebrootUpdates.sh 
	${HOME}/providerscripts/datastore/webroot-sync/ProcessIncomingWebrootUpdates.sh 
fi


${HOME}/providerscripts/datastore/webroot-sync/HousekeepAdditionsSyncing.sh
${HOME}/providerscripts/datastore/webroot-sync/HousekeepDeletionsSyncing.sh

if ( [ -f ${HOME}/runtime/webroot_sync/DISABLE_EXECUTION:${execution_order} ] )
then
	/bin/rm ${HOME}/runtime/webroot_sync/DISABLE_EXECUTION:${execution_order}
fi

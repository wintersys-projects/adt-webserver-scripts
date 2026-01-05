#!/bin/sh

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLED_SUCCESSFULLY"`" = "0" ] )
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
		historical="2"
	fi
	/bin/rm ${HOME}/runtime/webroot_sync/PREVIOUSEXECUTIONTIME:*
fi
	
/bin/touch ${HOME}/runtime/webroot_sync/PREVIOUSEXECUTIONTIME:`/usr/bin/date +%s`

#If a process has been running for a long time we don't want it blocking us
pids="`/bin/ps -A -o pid,cmd | /bin/grep "/webroot-sync/" | /bin/grep -v grep | /usr/bin/awk '{print $1}'`"
for pid in ${pids}
do
        minutes="`/bin/ps -o etime -p ${pid} | /usr/bin/tail -n +2 | /usr/bin/awk -F':' '{print $1}'`"
        if ( [ ${minutes} -gt 5 ] )
        then
                /usr/bin/kill -TERM ${pid}
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

if ( [ ! -d ${HOME}/runtime/webroot_sync/processed ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/processed
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/processed/historical ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/processed/historical
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/historical/incoming/additions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/historical/incoming/additions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/historical/incoming/deletions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/historical/incoming/deletions
fi

#if ( [ ! -d /var/www/html1 ] )
if ( [ "${historical}" = "1" ] )
then
	if ( [ "${historical}" = "1" ] )
	then
		${HOME}/providerscripts/datastore/webroot-sync/ProcessIncomingHistoricalWebrootUpdates.sh "full"
	elif ( [ "${historical}" = "2" ] )
	then
		${HOME}/providerscripts/datastore/webroot-sync/ProcessIncomingHistoricalWebrootUpdates.sh "partial" "${time_since_last_run}"
	fi
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

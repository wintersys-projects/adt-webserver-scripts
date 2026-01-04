#!/bin/sh

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLED_SUCCESSFULLY"`" = "0" ] )
then
	exit
fi

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

#If a process has been running for more than a minute we bow out gracefully

pids1="`/bin/ps -A -o pid,cmd |grep WebrootSyncingController.sh | /bin/grep -v grep | /bin/grep 'sleep 2'`"
pids2="`/bin/ps -A -o pid,cmd |grep WebrootSyncingController.sh | /bin/grep -v grep | /bin/grep 'sleep 15'`"
pids3="`/bin/ps -A -o pid,cmd |grep WebrootSyncingController.sh | /bin/grep -v grep | /bin/grep 'sleep 30'`"
pids4="`/bin/ps -A -o pid,cmd |grep WebrootSyncingController.sh | /bin/grep -v grep | /bin/grep 'sleep 45'`"

if ( [ "${execution_order}" = "2" ] )
then
        if ( [ "${pids1}" != "" ] )
        then
                exit
        fi
fi

if ( [ "${execution_order}" = "15" ] )
then
        if ( [ "${pids2}" != "" ] )
        then
                exit
        fi
fi

if ( [ "${execution_order}" = "30" ] )
then
        if ( [ "${pids3}" != "" ] )
        then
                exit
        fi
fi

if ( [ "${execution_order}" = "45" ] )
then
        if ( [ "${pids4}" != "" ] )
        then
                exit
        fi
fi

#If there was a very big change to our webroot then it might take longer than 15 seconds (set in cron) for the updates to 
#work their way through the system meaning that the instance of WebrootSyncingController.sh runs for longer than 15 seconds
#So we don't want concurrent processes running so we can skip the next invocation giving the previous invocation time to complete

ids_by_sleep="`/bin/ps -ef | grep WebrootSync | /bin/grep -v 'grep' | /bin/sed 's/.*sleep //g' | /usr/bin/awk '{print $1}'`"

if ( [ "`/bin/echo ${ids_by_sleep} | /bin/grep '2'`" != "" ] )
then
	expected_running="4" 
elif ( [ "`/bin/echo ${ids_by_sleep} | /bin/grep '15'`" != "" ] )
then
	expected_running="3"
elif ( [ "`/bin/echo ${ids_by_sleep} | /bin/grep '30'`" != "" ] )
then	
	expected_running="2"
elif ( [ "`/bin/echo ${ids_by_sleep} | /bin/grep '45'`" != "" ] )
then
	expected_running="1"
fi

if ( [ "${running}" -gt "${expected_running}" ] )
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

	if ( [ "${time_since_last_run}" -gt "300" ] )
	then
		historical="1"
	fi
	/bin/rm ${HOME}/runtime/webroot_sync/PREVIOUSEXECUTIONTIME:*
fi
	
/bin/touch ${HOME}/runtime/webroot_sync/PREVIOUSEXECUTIONTIME:`/usr/bin/date +%s`

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
        ${HOME}/providerscripts/datastore/webroot-sync/ProcessIncomingHistoricalWebrootUpdates.sh
fi

#Parallelise them to expedite the process
pids=""
${HOME}/providerscripts/datastore/webroot-sync/ProcessOutgoingWebrootUpdates.sh &
pids="${pids} $!"
${HOME}/providerscripts/datastore/webroot-sync/ProcessIncomingWebrootUpdates.sh &
pids="${pids} $!"

for pid in ${pids}
do
	wait ${pid}
done


${HOME}/providerscripts/datastore/webroot-sync/HousekeepAdditionsSyncing.sh
${HOME}/providerscripts/datastore/webroot-sync/HousekeepDeletionsSyncing.sh

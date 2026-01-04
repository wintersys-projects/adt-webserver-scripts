
if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLED_SUCCESSFULLY"`" = "0" ] )
then
	exit
fi

#If there was a very big change to our webroot then it might take longer than 15 seconds (set in cron) for the updates to 
#work their way through the system meaning that the instance of WebrootSyncingController.sh runs for longer than 15 seconds
#So we don't want concurrent processes running so we can skip the next invocation giving the previous invocation time to complete

running="`/bin/ps -ef | /bin/grep WebrootSyncingController.sh | /bin/grep -v grep | /bin/grep sleep | /usr/bin/wc -l`"
expected_running="`/usr/bin/crontab -l | /bin/grep WebrootSyncingController.sh | /usr/bin/wc -l`"

if ( [ "${running}" = "${expected_running}" ] )
then
	if ( [ ! -f ${HOME}/runtime/webroot_sync/AUTHORISED ] )
	then
        /bin/touch ${HOME}/runtime/webroot_sync/AUTHORISED
	fi
fi

/usr/bin/find  ${HOME}/runtime/webroot_sync/AUTHORISED -type f -not -newermt '-56 seconds' -delete

if ( [ ! -f ${HOME}/runtime/webroot_sync/AUTHORISED ] )
then
        exit
fi

historical="0"
if ( [ ! -f ${HOME}/runtime/webroot_sync/PREVIOUSEXECUTIONTIME:* ] )
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

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming/historical/additions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming/historical/additions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming/historical/deletions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming/historical/deletions
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

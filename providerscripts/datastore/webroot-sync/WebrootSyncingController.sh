
if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLED_SUCCESSFULLY"`" = "0" ] )
then
	exit
fi

running="`/bin/ps -ef | /bin/grep WebrootSyncingController.sh | /bin/grep -v grep | /usr/bin/wc -l`"
running="`/usr/bin/expr ${running} / 2`"
expected_running="`/usr/bin/crontab -l | /bin/grep WebrootSyncingController.sh | /usr/bin/wc -l`"

if ( [ "${running}" != "${expected_running}" ] )
then
        exit
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

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming/historical/additions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming/historical/additions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming/historical/deletions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming/historical/deletions
fi

if ( [ ! -d /var/www/html1 ] )
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

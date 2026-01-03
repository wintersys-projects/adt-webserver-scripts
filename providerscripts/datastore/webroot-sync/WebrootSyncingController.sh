

if ( [ "`/bin/ps -ef | /bin/grep WebrootSyncingController.sh | /bin/grep export`" != "" ] )
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

${HOME}/providerscripts/datastore/webroot-sync/ProcessOutgoingWebrootUpdates.sh
${HOME}/providerscripts/datastore/webroot-sync/ProcessIncomingWebrootUpdates.sh


${HOME}/providerscripts/datastore/webroot-sync/HousekeepAdditionsSyncing.sh
${HOME}/providerscripts/datastore/webroot-sync/HousekeepDeletionsSyncing.sh

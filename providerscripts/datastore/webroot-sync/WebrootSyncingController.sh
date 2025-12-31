
if ( [ ! -f ${HOME}/runtime/webroot_sync/SYNCING_INITIALISED ] )
then
  ${HOME}/providerscripts/datastore/webroot-sync/InitialiseWebrootSyncing.sh
  /bin/touch ${HOME}/runtime/webroot_sync/SYNCING_INITIALISED
fi


#${HOME}/providerscripts/datastore/webroot-sync/CollateIncomingAdditions.sh #Incoming additions are files that have been added to the webroots of other servers
#${HOME}/providerscripts/datastore/webroot-sync/CollateIncomingDeletions.sh #Incoming deletions are files that have been removed to the webroots of other servers
#${HOME}/providerscripts/datastore/webroot-sync/CollateOutgoingAdditions.sh #Outgoing additions are files that have been added from this server's webroot
#${HOME}/providerscripts/datastore/webroot-sync/CollateOutgoingDeletions.sh #Outgoing deletions are files that have been removed from this server's webroot


${HOME}/providerscripts/datastore/webroot-sync/CollateOutgoingWebrootUpdates.sh
${HOME}/providerscripts/datastore/webroot-sync/CollateIncomingWebrootUpdates.sh


${HOME}/providerscripts/datastore/webroot-sync/HousekeepAdditionsSyncing.sh
${HOME}/providerscripts/datastore/webroot-sync/HousekeepDeletionsSyncing.sh

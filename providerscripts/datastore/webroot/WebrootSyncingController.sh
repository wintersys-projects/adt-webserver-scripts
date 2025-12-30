
if ( [ ! -f ${HOME}/runtime/webroot_sync/SYNCING_INITIALISED ] )
then
  ${HOME}/providerscripts/datastore/webroot/InitialiseWebrootSyncing.sh
  /bin/touch ${HOME}/runtime/webroot_sync/SYNCING_INITIALISED
fi


${HOME}/providerscripts/datastore/webroot/CollateIncomingAdditions.sh #Incoming additions are files that have been added to the webroots of other servers
${HOME}/providerscripts/datastore/webroot/CollateIncomingDeletions.sh #Incoming deletions are files that have been removed to the webroots of other servers
${HOME}/providerscripts/datastore/webroot/CollateOutgoingAdditions.sh #Outgoing additions are files that have been added from this server's webroot
${HOME}/providerscripts/datastore/webroot/CollateOutgoingDeletions.sh #Outgoing deletions are files that have been removed from this server's webroot

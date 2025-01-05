if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLED_SUCCESSFULLY"`" != "1" ] )
then
        exit
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" = "1" ] )
then
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/SyncRemoteFilesForManifests.sh "0" &
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/SyncRemoteFilesForManifests.sh "10" &
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/SyncRemoteFilesForManifests.sh "20" &
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/SyncRemoteFilesForManifests.sh "30" &
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/SyncRemoteFilesForManifests.sh "40" &
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/SyncRemoteFilesForManifests.sh "50" &
fi

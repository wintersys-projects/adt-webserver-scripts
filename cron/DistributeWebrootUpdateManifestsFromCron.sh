if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" != "1" ] )
then
        ${HOME}providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh &
        /bin/sleep 10
        ${HOME}providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh &
        /bin/sleep 10
        ${HOME}providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh &
        /bin/sleep 10
        ${HOME}providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh &
        /bin/sleep 10
        ${HOME}providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh &
        /bin/sleep 10
        ${HOME}providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh &
fi




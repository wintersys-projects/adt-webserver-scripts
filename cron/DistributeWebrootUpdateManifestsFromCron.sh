
if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLED_SUCCESSFULLY"`" != "1" ] )
then
        exit
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" = "1" ] )
then
        ${HOME}/providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "0" &
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "10" &
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "20" &
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "30" &
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "40" &
        /bin/sleep 10
        ${HOME}/providerscripts/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "50" &
fi




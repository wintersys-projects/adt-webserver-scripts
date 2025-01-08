
if ( [ -f ${HOME}/runtime/WEBSERVER_READY ] )
then
 # for interval in 0 10 20 30 40 50
 # do
 #   /bin/sleep ${interval}
    ${HOME}/providerscripts/utilities/housekeeping/RsyncWebroots.sh
    /bin/sleep 30
    ${HOME}/providerscripts/utilities/housekeeping/EnforceWebrootDeletes.sh
 # done
fi

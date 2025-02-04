
chosen_webserver_ip"${1}"

if ( [ "${chosen_webserver_ip}" != "" ] )
then
	if ( [ ! -f /usr/bin/rsync ] )
 	then
  		/usr/bin/apt-get -qq -y install rsync
    	fi
	${HOME}/providerscripts/utilities/housekeeping/RsyncEntireMachine.sh ${chosen_webserver_ip}
 	${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "AUTOSCALED" "1"
	${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "MYPUBLICIP" "`${HOME}/providerscripts/utilities/processing/GetPublicIP.sh`"
	${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "MYIP" "`${HOME}/providerscripts/utilities/processing/GetIP.sh`"
	${HOME}/providerscripts/utilities/status/CheckNetworkManagerStatus.sh
 
  	if ( [ -z `/bin/ls ${HOME}/runtime/otherwebserverips` ] )
	then
 		/bin/rm ${HOME}/runtime/otherwebserverips/*
   	fi
    
     	${HOME}/providerscripts/utilities/processing/UpdateIPs.sh
      	${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh cron restart
	${HOME}/providerscripts/webserver/RestartWebserver.sh 
 
      	/bin/touch ${HOME}/runtime/SUCCESSFULLY_RSYNC_BUILT
       
        if ( [ -f ${HOME}/runtime/BUILD_IN_PROGRESS ] )
	then
       		/bin/rm ${HOME}/runtime/BUILD_IN_PROGRESS
	fi
fi

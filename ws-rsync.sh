if ( [ "${chosen_webserver_ip}" != "" ] )
then
	if ( [ ! -f /usr/bin/rsync ] )
 	then
  		/usr/bin/apt-get -qq -y install rsync
    	fi
	${HOME}/providerscripts/utilities/housekeeping/RsyncEntireMachine.sh ${chosen_webserver_ip}
 	${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "AUTOSCALED" "1"
	${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "MYPUBLICIP" "${my_ip}"
	${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "MYIP" "${my_private_ip}"
	${HOME}/providerscripts/utilities/status/CheckNetworkManagerStatus.sh
  	if ( [ -z `/bin/ls ${HOME}/runtime/otherwebserverips` ] )
	then
 		/bin/rm ${HOME}/runtime/otherwebserverips/*
   	fi
     	${HOME}/providerscripts/utilities/processing/UpdateIPs.sh
      	${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh cron restart
	${HOME}/providerscripts/webserver/RestartWebserver.sh 
      	/bin/touch ${HOME}/runtime/SUCCESSFULLY_RSYNC_BUILT
       	/bin/rm ${HOME}/runtime/BUILD_IN_PROGRESS
	exit
fi

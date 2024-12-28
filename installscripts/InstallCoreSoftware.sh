if ( [ ! -d ${HOME}/runtime/installedsoftware ] )
then
  /bin/mkdir -p ${HOME}/runtime/installedsoftware
fi

>&2 /bin/echo "${0} UpdateAndUpgrade.sh"
${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallGo.sh"
${HOME}/installscripts/InstallGo.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallCurl.sh"
${HOME}/installscripts/InstallCurl.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallLibioSocketSSL.sh"
${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallLibnetSSLLeay.sh"
${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallSendEmail.sh"
${HOME}/installscripts/InstallSendEmail.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallNetworkManager.sh"
${HOME}/installscripts/InstallNetworkManager.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallJQ.sh"
${HOME}/installscripts/InstallJQ.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallUnzip.sh"
${HOME}/installscripts/InstallUnzip.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallSSHPass.sh"
${HOME}/installscripts/InstallSSHPass.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallSysStat.sh"
${HOME}/installscripts/InstallSysStat.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallFirewall.sh"
${HOME}/installscripts/InstallFirewall.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallDatastoreTools.sh"
${HOME}/installscripts/InstallDatastoreTools.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallDatabaseClient.sh"
${HOME}/installscripts/InstallDatabaseClient.sh  ${BUILDOS} 
>&2 /bin/echo "${0} InstallRsync.sh"
${HOME}/installscripts/InstallRsync.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallCron.sh"
${HOME}/installscripts/InstallCron.sh ${BUILDOS} 

${HOME}/installscripts/InstallMonitoringGear.sh 
>&2 /bin/echo "${0} Installing Datastore tools"
. ${HOME}/installscripts/InstallDatastoreTools.sh 

# Install the language engine for whatever language your application is written in
>&2 /bin/echo "${0} Installing Application Language"
${HOME}/installscripts/InstallApplicationLanguage.sh "${APPLICATION_LANGUAGE}" 
>&2 /bin/echo "${0} Installing Webserver"
${HOME}/providerscripts/webserver/InstallWebserver.sh  

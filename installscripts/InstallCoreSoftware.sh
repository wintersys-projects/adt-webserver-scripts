
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
>&2 /bin/echo "${0} InstallS3FS.sh"
${HOME}/installscripts/InstallS3FS.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallGoofyFS.sh"
${HOME}/installscripts/InstallGoofyFS.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallRsync.sh"
${HOME}/installscripts/InstallRsync.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallCron.sh"
${HOME}/installscripts/InstallCron.sh ${BUILDOS}

${HOME}/installscripts/InstallMonitoringGear.sh
>&2 /bin/echo "${0} Installing Datastore tools"
/bin/echo "${0} Installing Datastore tools" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
. ${HOME}/installscripts/InstallDatastoreTools.sh
# Install the language engine for whatever language your application is written in
>&2 /bin/echo "${0} Installing Application Language"
/bin/echo "${0} Installing Application Language: ${APPLICATION_LANGUAGE}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
${HOME}/installscripts/InstallApplicationLanguage.sh "${APPLICATION_LANGUAGE}"
>&2 /bin/echo "${0} Installing Webserver"
/bin/echo "${0} Installing Webserver: ${WEBSERVER_CHOICE} for ${WEBSITE_NAME} at: ${WEBSITE_URL}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
${HOME}/providerscripts/webserver/InstallWebserver.sh 

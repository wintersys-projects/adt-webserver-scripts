
if ( [ ! -d ${HOME}/runtime/installedsoftware ] )
then
  /bin/mkdir -p ${HOME}/runtime/installedsoftware
fi
pids=""
>&2 /bin/echo "${0} UpdateAndUpgrade.sh"
${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallGo.sh"
${HOME}/installscripts/InstallGo.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallCurl.sh"
${HOME}/installscripts/InstallCurl.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallLibioSocketSSL.sh"
${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallLibnetSSLLeay.sh"
${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallSendEmail.sh"
${HOME}/installscripts/InstallSendEmail.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallNetworkManager.sh"
${HOME}/installscripts/InstallNetworkManager.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallJQ.sh"
${HOME}/installscripts/InstallJQ.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallUnzip.sh"
${HOME}/installscripts/InstallUnzip.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallSSHPass.sh"
${HOME}/installscripts/InstallSSHPass.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallSysStat.sh"
${HOME}/installscripts/InstallSysStat.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallFirewall.sh"
${HOME}/installscripts/InstallFirewall.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallDatastoreTools.sh"
${HOME}/installscripts/InstallDatastoreTools.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallDatabaseClient.sh"
${HOME}/installscripts/InstallDatabaseClient.sh  ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallRsync.sh"
${HOME}/installscripts/InstallRsync.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallCron.sh"
${HOME}/installscripts/InstallCron.sh ${BUILDOS} &
pids="${pids} $!"

${HOME}/installscripts/InstallMonitoringGear.sh &
pids="${pids} $!"
>&2 /bin/echo "${0} Installing Datastore tools"
/bin/echo "${0} Installing Datastore tools" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
. ${HOME}/installscripts/InstallDatastoreTools.sh &
pids="${pids} $!"
# Install the language engine for whatever language your application is written in
>&2 /bin/echo "${0} Installing Application Language"
/bin/echo "${0} Installing Application Language: ${APPLICATION_LANGUAGE}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
${HOME}/installscripts/InstallApplicationLanguage.sh "${APPLICATION_LANGUAGE}" &
pids="${pids} $!"
>&2 /bin/echo "${0} Installing Webserver"
/bin/echo "${0} Installing Webserver: ${WEBSERVER_CHOICE} for ${WEBSITE_NAME} at: ${WEBSITE_URL}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
${HOME}/providerscripts/webserver/InstallWebserver.sh  &
pids="${pids} $!"

for pid in ${pids}
do
        wait ${pid}
done

while ( [ ! -f ${HOME}/runtime/installedsoftware/InstallPHPBase.sh ] )
do
	/bin/sleep 10
done

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Sending notification email"
/bin/echo "${0} Sending notification email that a webserver has been built" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

${HOME}/providerscripts/email/SendEmail.sh "A WEBSERVER HAS BEEN SUCCESSFULLY BUILT" "A Webserver has been successfully built and primed as is rebooting ready for use" "INFO"


${HOME}/providerscripts/utilities/processing/UpdateIPs.sh
${HOME}/providerscripts/application/configuration/SetApplicationConfiguration.sh
${HOME}/providerscripts/utilities/housekeeping/CleanupAfterBuild.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Rebooting post install...."
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log


/bin/touch ${HOME}/runtime/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK
/usr/bin/touch ${HOME}/runtime/WEBSERVER_READY

${HOME}/providerscripts/webserver/RestartWebserver.sh

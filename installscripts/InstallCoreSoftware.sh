
#while ( [ ! -f /home/SOFTWARE_FOUNDATION_INSTALLED ] )
#do
#  /bin/sleep 1
#done

if ( [ ! -d ${HOME}/runtime/installedsoftware ] )
then
  /bin/mkdir -p ${HOME}/runtime/installedsoftware
fi

if ( [ "${1}" != "" ] )
then
    buildos="${1}"
fi

if ( [ "${buildos}" = "" ] )
then
    BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
else 
    BUILDOS="${buildos}"
fi

APPLICATION_LANGUAGE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"

#>&2 /bin/echo "${0} UpdateAndUpgrade.sh"
#${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
#/bin/sed -i "s/mirrors.linode.com/mirror.katapult.io/g" /etc/apt/sources.list
#/bin/sed -i "s/mirrors.digitalocean.com/mirror.katapult.io/g" /etc/apt/mirrors/debian.list



>&2 /bin/echo "${0} InitialUpdate.sh"
${HOME}/installscripts/InitialUpdate.sh ${BUILDOS}

>&2 /bin/echo "${0} InstallNetworkManager.sh"
${HOME}/installscripts/InstallNetworkManager.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallFirewall.sh"
${HOME}/installscripts/InstallFirewall.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallDatastoreTools.sh"
${HOME}/installscripts/InstallDatastoreTools.sh  ${BUILDOS}

if ( [ ! -f /usr/bin/s3cmd ] && [ ! -f /usr/bin/s5cmd ] )
then
>&2 /bin/echo "${0} Failed to install essential datastore tooling, I have to exit"
  exit
fi
#>&2 /bin/echo "${0} InstallUnzip.sh"
#${HOME}/installscripts/InstallUnzip.sh ${BUILDOS} 

>&2 /bin/echo "${0} Installing Webserver"
#WEBSERVER_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`" 
#if ( ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] && [ "${WEBSERVER_CHOICE}" = "NGINX" ] ) || ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:source'`" = "1" ] && [ "${WEBSERVER_CHOICE}" = "APACHE" ] ) || ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] && [ "${WEBSERVER_CHOICE}" = "LIGHTTPD" ] ) )
#then
#  ${HOME}/installscripts/InstallWebserver.sh &
#else
#  ${HOME}/installscripts/InstallWebserver.sh 
#fi

${HOME}/installscripts/InstallWebserver.sh ${BUILDOS}

>&2 /bin/echo "${0} Installing Application Language"
${HOME}/installscripts/InstallApplicationLanguage.sh "${APPLICATION_LANGUAGE}"

>&2 /bin/echo "${0} InstallJQ.sh" #not needed
${HOME}/installscripts/InstallJQ.sh ${BUILDOS}

>&2 /bin/echo "${0} InstallDatabaseClient.sh"
${HOME}/installscripts/InstallDatabaseClient.sh  ${BUILDOS}

>&2 /bin/echo "${0} InstallRsync.sh" #not needed
${HOME}/installscripts/InstallRsync.sh  ${BUILDOS}

>&2 /bin/echo "${0} InstallCron.sh" #not needed
${HOME}/installscripts/InstallCron.sh ${BUILDOS}

>&2 /bin/echo "${0} InstallEmailUtil.sh"
${HOME}/installscripts/InstallEmailUtil.sh ${BUILDOS}

#>&2 /bin/echo "${0} InstallMonitoringGear.sh"
#${HOME}/installscripts/InstallMonitoringGear.sh 

>&2 /bin/echo "${0} InstallWPCLI.sh"
${HOME}/installscripts/InstallWPCLI.sh ${BUILDOS} &

>&2 /bin/echo "${0} InstallLego.sh"
${HOME}/installscripts/InstallLego.sh ${BUILDOS} &

>&2 /bin/echo "${0} InstallGo.sh"
${HOME}/installscripts/InstallGo.sh ${BUILDOS} &

#>&2 /bin/echo "${0} InstallCurl.sh" #not needed
#${HOME}/installscripts/InstallCurl.sh ${BUILDOS} #not needed

#>&2 /bin/echo "${0} InstallLibioSocketSSL.sh" #not sure if needed
#${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS} 
#>&2 /bin/echo "${0} InstallLibnetSSLLeay.sh" #not sure if needed
#${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS} 



#>&2 /bin/echo "${0} InstallSSHPass.sh" #not needed
#${HOME}/installscripts/InstallSSHPass.sh ${BUILDOS} #not needed

#>&2 /bin/echo "${0} InstallSysStat.sh"
#${HOME}/installscripts/InstallSysStat.sh ${BUILDOS} 





/bin/touch ${HOME}/runtime/ALL_CORE_SOFTWARE_INSTALLED



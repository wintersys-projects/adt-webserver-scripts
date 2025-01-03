
if ( [ ! -d ${HOME}/runtime/installedsoftware ] )
then
  /bin/mkdir -p ${HOME}/runtime/installedsoftware
fi

BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
APPLICATION_LANGUAGE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"

>&2 /bin/echo "${0} UpdateAndUpgrade.sh"
${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}

>&2 /bin/echo "${0} InstallNetworkManager.sh"
${HOME}/installscripts/InstallNetworkManager.sh ${BUILDOS} 

>&2 /bin/echo "${0} InstallFirewall.sh"
${HOME}/installscripts/InstallFirewall.sh ${BUILDOS} 

>&2 /bin/echo "${0} InstallDatastoreTools.sh"
${HOME}/installscripts/InstallDatastoreTools.sh ${BUILDOS} 

>&2 /bin/echo "${0} Installing Application Language"
${HOME}/installscripts/InstallApplicationLanguage.sh "${APPLICATION_LANGUAGE}" 

>&2 /bin/echo "${0} Installing Webserver"
WEBSERVER_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`" 
if ( ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] && [ "${WEBSERVER_CHOICE}" = "NGINX" ] ) || ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:source'`" = "1" ] && [ "${WEBSERVER_CHOICE}" = "APACHE" ] ) || ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] && [ "${WEBSERVER_CHOICE}" = "LIGHTTPD" ] ) )
then
  ${HOME}/providerscripts/webserver/InstallWebserver.sh &
  while ( [ ! -f ${HOME}/runtime/ESSENTIAL_SOURCEBUILD_SOFTWARE_INSTALLED ] )
  do
    /bin/sleep 1
  done
else
  ${HOME}/providerscripts/webserver/InstallWebserver.sh 
fi

#if ( [ "${1}" = "preinstall" ] )
#then
 # scripts="`/bin/cat ${HOME}/installscripts/InstallCoreSoftware.sh | /bin/grep BUILDOS | /bin/grep -v "Up.*" | /usr/bin/awk '{print $1}'`"
 # 
 # package_names=""
#
 # for script in ${scripts}
 # do
 #       script="`/bin/echo ${script} | /bin/sed -e 's,\${HOME},'${HOME}',g'`"
 #       package_names="${package_names} `/bin/cat ${script} | /bin/grep DEBIAN_FRONTEND | /usr/bin/awk '{print $8}' | /usr/bin/sort -u | /usr/bin/uniq | /usr/bin/tr '\n' ' '`"
 # done

#  apt=""
#  if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
#  then
#        apt="/usr/bin/apt-get"
#  elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
#  then
#        apt="/usr/sbin/apt-fast"
#  fi

 # if ( [ "${apt}" != "" ] )
 # then
 #       if ( [ "${BUILDOS}" = "ubuntu" ] )
 #       then
 #               DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install ${package_names}
 #       fi
 #       if ( [ "${BUILDOS}" = "debian" ] )
 #       then
 #               DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install ${package_names}
 #       fi
 # fi
#fi

>&2 /bin/echo "${0} InstallGo.sh"
${HOME}/installscripts/InstallGo.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallCurl.sh"
${HOME}/installscripts/InstallCurl.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallLibioSocketSSL.sh"
${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallLibnetSSLLeay.sh"
${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallEmailUtil.sh"
${HOME}/installscripts/InstallEmailUtil.sh ${BUILDOS} 

>&2 /bin/echo "${0} InstallJQ.sh"
${HOME}/installscripts/InstallJQ.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallUnzip.sh"
${HOME}/installscripts/InstallUnzip.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallSSHPass.sh"
${HOME}/installscripts/InstallSSHPass.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallSysStat.sh"
${HOME}/installscripts/InstallSysStat.sh ${BUILDOS} 


>&2 /bin/echo "${0} InstallDatabaseClient.sh"
${HOME}/installscripts/InstallDatabaseClient.sh  ${BUILDOS} 
>&2 /bin/echo "${0} InstallRsync.sh"
${HOME}/installscripts/InstallRsync.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallCron.sh"
${HOME}/installscripts/InstallCron.sh ${BUILDOS} 
${HOME}/installscripts/InstallMonitoringGear.sh 

/bin/touch ${HOME}/runtime/ALL_CORE_SOFTWARE_INSTALLED



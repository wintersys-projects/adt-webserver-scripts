if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" != "1" ] )
then
        exit
fi

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

directories_to_miss="none"
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh PERSISTASSETSTOCLOUD:1`" = "1" ] )
then
        directories_to_miss="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
fi


if ( [ ! -d ${HOME}/runtime/webroot_manifests ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_manifests 
fi

if ( [ "${directories_to_miss}" != "none" ] )
then
        command="/usr/bin/find /var/www/html "
        command_body=""
        for directory_to_miss in ${directories_to_miss}
        do
                command_body="${command_body} -path /var/www/html/${directory_to_miss} -prune -o "
        done
        command="${command} ${command_body} -type f -mmin -1  -print"
else
        command="/usr/bin/find /var/www/html -type f -mmin -1 -print"
fi

invocation_time="${1}"

if ( [ -f ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}-${invocation_time} ] )
then
        /bin/rm ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}-${invocation_time}
fi
machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"
${command} > ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}-${invocation_time}

if ( [ "`/bin/cat ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}-${invocation_time}`" != "" ] )
then
        for file in `/bin/cat ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}-${invocation_time}`
        do
                file_plus_epoch="${file}:`/usr/bin/date -r ${file} +"%s"`"
                if ( [ "`/bin/grep "${file_plus_epoch}" ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-*`" = "" ] )
                then
                        /bin/echo ${file_plus_epoch} >> ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}.$$-${invocation_time}
                fi
        done
fi


if ( [ ! -f ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}.$$-${invocation_time} ] )
then
        /bin/cp /dev/null ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}-${invocation_time}
else
        /bin/mv ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}.$$-${invocation_time} ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}-${invocation_time}
fi

if ( [ -f ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}-${invocation_time} ] )
then
        webserver_ips="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/* | /bin/sed "s/${machine_ip}//g" | /bin/sed 's/  / /g'`"
        for ip in ${webserver_ips}
        do
                if ( [ "`/bin/cat ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}-${invocation_time}`" != "" ] )
                then
                        if ( [ "`/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${ip} "${SUDO} /bin/ls ${HOME}/runtime/webroot_manifests"`" = "" ] )
                        then
                                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${ip} "${SUDO} /bin/mkdir -p ${HOME}/runtime/webroot_manifests; ${SUDO} /bin/chmod 755 ${HOME}/runtime/webroot_manifests"
                        fi
                        /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -P ${SSH_PORT} ${HOME}/runtime/webroot_manifests/webroot_manifest_outgoing-${machine_ip}-${invocation_time} ${SERVER_USER}@${ip}:${HOME}/runtime/webroot_manifests/webroot_manifest_incoming-${machine_ip}-${invocation_time}
                fi
        done
fi

directories_to_miss=""
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh PERSISTASSETSTOCLOUD:1`" = "1" ] )
then
        directories_to_miss="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
fi

exclude_command=""

if ( [ "${directories_to_miss}" != "" ] )
then
        for directory in ${directories_to_miss}
        do
                exclude_command="${exclude_command} ! -path '/var/www/html/${directory}/* "
        done
fi

if ( [ ! -d ${HOME}/runtime/webroot_audit ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_audit 
fi

if ( [ -f ${HOME}/runtime/webroot_audit/audit.dat ] )
then
        /bin/mv ${HOME}/runtime/webroot_audit/audit.dat ${HOME}/runtime/webroot_audit/audit.dat.previous
fi

/usr/bin/find /var/www/html ${exclude_command} > ${HOME}/runtime/webroot_audit/audit.dat
if ( [ -f ${HOME}/runtime/webroot_audit/audit.dat.previous ] )
then
        /usr/bin/diff ${HOME}/runtime/webroot_audit/audit.dat.previous ${HOME}/runtime/webroot_audit/audit.dat | /bin/grep  "^<" | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/webroot_audit/audit_results.dat
else
        /bin/cp /dev/null ${HOME}/runtime/webroot_audit/audit_results.dat
fi

if ( [ "`/bin/cat ${HOME}/runtime/webroot_audit/audit_results.dat`" != "" ] )
then
        delete_command="/bin/rm "
        for file in `/bin/cat ${HOME}/runtime/webroot_audit/audit_results.dat`
        do
                delete_command="${delete_command} ${file}"
        done

        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

        for webserver_ip in ${other_webserver_ips}
        do
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} ${delete_command}"
        done
fi

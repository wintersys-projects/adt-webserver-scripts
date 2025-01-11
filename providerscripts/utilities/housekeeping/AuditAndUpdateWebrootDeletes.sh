SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "


if ( [ ! -d ${HOME}/runtime/webroot_audit ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_audit
fi

if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat ] )
then
        /bin/mv ${HOME}/runtime/webroot_audit/webroot_file_list.dat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous
fi

/usr/bin/find /var/www/html/ -type f > ${HOME}/runtime/webroot_audit/webroot_file_list.dat

if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat ] && [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous ] )
then
        /usr/bin/diff ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous ${HOME}/runtime/webroot_audit/webroot_file_list.dat > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted
fi

#deletion_command="/bin/rm "
#if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ] )
#then
#        files_to_delete=`/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted | /bin/grep "^<" | /usr/bin/awk '{print $NF}' | /usr/bin/tr '\n' ' '`
#        deletion_command="${deletion_command} ${files_to_delete}" 
#fi

if ( [ "${files_to_delete}" != "" ] )
then
        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

        for webserver_ip in ${other_webserver_ips}
        do
                /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -P ${SSH_PORT} ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ${SERVER_USER}@${webserver_ip}:/tmp/webroot_file_list.dat.deleted
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv /tmp/webroot_file_list.dat.deleted ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted.${machine_ip}"
        done
fi
/bin/sleep 10
if ( [ "`/usr/bin/find  ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted.* | /usr/bin/wc -l`" = "`/bin/echo ${other_webserver_ips} | /usr/bin/wc -l`" ] )
then
        for file in `/bin/cat  ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted.*`
        do
                /bin/rm ${file}
        done
fi

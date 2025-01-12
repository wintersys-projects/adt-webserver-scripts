SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

if ( [ ! -d ${HOME}/runtime/webroot_audit ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_audit
fi

for archive in `/usr/bin/find ${HOME}/runtime/webroot_audit -name "*tar.gz"`
do
        /bin/tar xvfz ${archive} -C / --keep-newer-files
        if ( [ "$?" = "0" ] )
        then
                /bin/rm ${archive}
        fi
done

for deletes_list in `/usr/bin/find ${HOME}/runtime/webroot_audit -name "*delete*"`
do
        for file in ${deletes_list}
        do
                /bin/rm ${file}
        done
        /bin/rm ${deletes_list}
done

${HOME}/providerscripts/utilities/security/EnforcePermissions.sh

if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat ] )
then
        /bin/mv ${HOME}/runtime/webroot_audit/webroot_file_list.dat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous
fi

/usr/bin/find /var/www/html/ -type f > ${HOME}/runtime/webroot_audit/webroot_file_list.dat

if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat ] && [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous ] )
then
        /usr/bin/diff ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous ${HOME}/runtime/webroot_audit/webroot_file_list.dat | /bin/grep "^<" | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted
        /usr/bin/diff ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous ${HOME}/runtime/webroot_audit/webroot_file_list.dat | /bin/grep "^>" | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.added
fi

/usr/bin/find /var/www/html/ -type f -mmin -1 > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified.processing

/bin/grep -vxf  ${HOME}/runtime/webroot_audit/webroot_file_list.dat.added ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified.processing > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified

/bin/rm ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified.processing

/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.added ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates

if ( [ "`/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates`" != "" ] )
then
        /usr/bin/tar -cfzp ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz -T ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates
fi

if ( [ -s ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz ] )
then
        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

        for webserver_ip in ${other_webserver_ips}
        do
                /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -P ${SSH_PORT} ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz ${SERVER_USER}@${webserver_ip}:/tmp/webroot_updates.${machine_ip}.tar.gz
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv  /tmp/webroot_updates.${machine_ip}.tar.gz ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz"
                /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -P ${SSH_PORT} ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ${SERVER_USER}@${webserver_ip}:/tmp/webroot_deletes.${machine_ip}
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv  /tmp/webroot_deletes.${machine_ip} ${HOME}/runtime/webroot_audit/webroot_deletes.${machine_ip}
        done
fi



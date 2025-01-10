if ( [ "`/usr/bin/ps -ef | /bin/grep 'inotify' | /bin/grep -v grep`" = "" ] )
then
        /usr/bin/inotifywait -q -m -r -e delete,modify,create -o /tmp/file --exclude '/\.[^/]*$' /var/www/html 
fi

if ( [ ! -d ${HOME}/runtime/webroot_audit ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_audit
fi

#Look for files that are 1 minute old or younger if none then don't rsync if there are some then rsync exlude images directory and so on from syncing process

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

/bin/cp /tmp/file /tmp/processing_for_deletion

candidate_deleted_files=`/bin/cat /tmp/processing_for_deletion | /bin/grep DELETE | /bin/grep -v ISDIR | /usr/bin/awk '{print $1,$NF}' | /bin/sed 's/ //g'`

for candidate_deleted_file in ${candidate_deleted_files}
do
        if ( [ ! -f ${candidate_deleted_file} ] && [ ! -d ${candidate_deleted_file} ] )
        then
                /bin/echo "${candidate_deleted_file}" >> /tmp/approved_for_deletion
        fi
done

deletion_command="/bin/rm "

if ( [ -f /tmp/approved_for_deletion ] )
then
        if ( [ "`/bin/cat /tmp/approved_for_deletion`" != "" ] )
        then
                for deleted_file in `/bin/cat /tmp/approved_for_deletion`
                do
                        deletion_command="${deletion_command} ${deleted_file} "
                done
        fi
fi

/bin/cp /tmp/file /tmp/processing_for_copying

candidate_copying_files=`/bin/cat /tmp/processing_for_copying | /bin/egrep "(MODIFY|CREATE)" | /bin/grep -v ISDIR | /usr/bin/awk '{print $1,$NF}' | /bin/sed 's/ //g'`

for candidate_copying_file in ${candidate_copying_files}
do
        if ( [ -f ${candidate_copying_file} ] && [ ! -d ${candidate_copying_file} ] )
        then
                /bin/echo "${candidate_copying_file}" >> /tmp/approved_for_copying
        fi
done

/bin/rm /tmp/file

for webserver_ip in ${other_webserver_ips}
do
        /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -P ${SSH_PORT}  /tmp/approved_for_copying ${SERVER_USER}@${webserver_ip}:${HOME}/runtime/webroot_audit/files_to_copy:${machine_ip}
        /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -P ${SSH_PORT}  /tmp/approved_for_deletion ${SERVER_USER}@${webserver_ip}:${HOME}/runtime/webroot_audit/files_to_delete:${machine_ip}
done

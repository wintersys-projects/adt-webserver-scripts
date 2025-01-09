set -x

#exec 1>> /tmp/out
#exec 2>> /tmp/err

if ( [ "`/usr/bin/ps -ef | /bin/grep 'inotify' | /bin/grep -v grep`" = "" ] )
then
        /usr/bin/inotifywait -q -m -r -e delete -o /tmp/file --exclude '/\.[^/]*$' /var/www/html 
fi

#Look for files that are 1 minute old or younger if none then don't rsync if there are some then rsync exlude images directory and so on from syncing process

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

if ( [ -f ${HOME}/runtime/WEBROOT_AUDIT_RUNNING ] )
then
        /bin/rm -r ${HOME}/runtime/webroot_audit
else
        /bin/touch ${HOME}/runtime/WEBROOT_AUDIT_RUNNING
fi

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
                exclude_command="${exclude_command} --exclude=${directory} "
        done
fi
        
other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

/bin/mv /tmp/file /tmp/processing_for_deletion

candidate_deleted_files=`/bin/cat /tmp/processing_for_deletion | /bin/grep DELETE | /bin/grep -v ISDIR | /usr/bin/awk '{print $1,$NF}' | /bin/sed 's/ //g'`

for candidate_deleted_file in ${candidate_deleted_files}
do
        if ( [ ! -f ${candidate_deleted_file} ] && [ ! -d ${candidate_deleted_file} ] )
        then
                /bin/echo "${candidate_deleted_file}" >> /tmp/approved_for_deletion
        fi
done

deletion_command="/bin/rm "

if ( [ "`/bin/cat /tmp/approved_for_deletion`" != "" ] )
then
        for deleted_file in `/bin/cat /tmp/approved_for_deletion`
        do
                deletion_command="${deletion_command} ${deleted_file} "
        done
fi

/bin/touch ${HOME}/runtime/RSYNC_READY

if ( [ "${deletion_command}" != "/bin/rm " ] )
then
        for webserver_ip in ${other_webserver_ips}
        do
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} ${deletion_command}"
        done
fi

for webserver_ip in ${other_webserver_ips}
do
        count="0"
        while ( [ "`/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/ls ${HOME}/runtime/RSYNC_READY"`" = "" ] && [ "${count}" -lt "5" ] )
        do
                /bin/sleep 5
                count="`/usr/bin/expr ${count} + 1`"
        done
        if ( [ "${count}" -ne "5" ] )
        then
                /usr/bin/rsync -azrpu ${exclude_command} -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /usr/bin/rsync " /var/www/html/ ${SERVER_USER}@${webserver_ip}:/var/www/html
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} ${HOME}/providerscripts/utilities/security/EnforcePermissions.sh"
              #  /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -P ${SSH_PORT}  ${HOME}/runtime/webroot_audit/audit_results.dat ${SERVER_USER}@${webserver_ip}:/tmp/audit_results.dat.${machine_ip}
              #  /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv /tmp/audit_results.dat.${machine_ip} ${HOME}/runtime/webroot_audit/audit_results.dat.${machine_ip}"
        fi
done

#${HOME}/providerscripts/utilities/housekeeping/AuditWebrootDeletes.sh

#/bin/cat ${HOME}/runtime/webroot_audit/audit_results.dat* | /usr/bin/sort -u >> ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat


#for file in `/bin/cat ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat`
#do
#        /bin/rm ${file}
#        /bin/sed -i "s,^${file}$,,g" ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat
#done

#/bin/sed -i '/^$/d' ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat

/usr/bin/find /var/www/html -type d -empty -delete

/bin/rm ${HOME}/runtime/WEBROOT_AUDIT_RUNNING







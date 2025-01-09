set -x

exec 1>> /tmp/out
exec 2>> /tmp/err

#Look for files that are 1 minute old or younger if none then don't rsync if there are some then rsync exlude images directory and so on from syncing process

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

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

${HOME}/providerscripts/utilities/housekeeping/AuditWebrootDeletes.sh

/bin/cat ${HOME}/runtime/webroot_audit/audit_results.dat* | /usr/bin/sort -u >> ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat

#for file in `/bin/cat ${HOME}/runtime/webroot_audit/audit_results.dat* | /usr/bin/sort -u` 
#do
#        if ( [ "`/bin/grep ${file} ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat`" = "" ] )
#        then
#                /bin/echo ${file} >> ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat
#        fi
#done

for file in `/bin/cat ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat`
do
        /bin/rm ${file}
        /bin/sed -i "s,^${file}$,,g" ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat
done

/bin/sed -i '/^$/d' ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat

/bin/touch ${HOME}/runtime/RSYNC_READY

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
                /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -P ${SSH_PORT}  ${HOME}/runtime/webroot_audit/audit_results.dat ${SERVER_USER}@${webserver_ip}:/tmp/audit_results.dat.${machine_ip}
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv /tmp/audit_results.dat.${machine_ip} ${HOME}/runtime/webroot_audit/audit_results.dat.${machine_ip}"
        fi
done

${HOME}/providerscripts/utilities/housekeeping/AuditWebrootDeletes.sh

/bin/cat ${HOME}/runtime/webroot_audit/audit_results.dat* | /usr/bin/sort -u >> ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat


for file in `/bin/cat ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat`
do
        /bin/rm ${file}
        /bin/sed -i "s,^${file}$,,g" ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat
done

/bin/sed -i '/^$/d' ${HOME}/runtime/webroot_audit/aggregate_audit_results.dat

/usr/bin/find /var/www/html -type d -empty -delete






SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

${HOME}/providerscripts/utilities/housekeeping/AuditAndUpdateWebrootDeletes.sh

 ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted

#deletion_command="/bin/rm "
#if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ] )
#then
#        files_to_delete=`/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted | /bin/grep "^<" | /usr/bin/awk '{print $NF}' | /usr/bin/tr '\n' ' '`
#        deletion_command="${deletion_command} ${files_to_delete}" 
#fi

#machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"
${HOME}/providerscripts/datastore/configwrapper/SyncWebrootToDatastore.sh
${HOME}/providerscripts/datastore/configwrapper/SyncDatastoreToWebroot.sh

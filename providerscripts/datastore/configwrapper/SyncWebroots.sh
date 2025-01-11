#SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
#SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
#SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
#ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
#CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

${HOME}/providerscripts/utilities/housekeeping/AuditAndUpdateWebrootDeletes.sh

machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ] )
then
 ${HOME}/providerscripts/datastore/PutToConfigDatastore.sh ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted webroot-deletes/webroot_file_list.dat.deleted.${machine_ip}
fi
if ( [ ! -d ${HOME}/runtime/webroot_audit/deletes_aggregate ] )
then
 /bin/mkdir -p ${HOME}/runtime/webroot_audit/deletes_aggregate
fi
${HOME}/providerscripts/datastore/GetFromConfigDatastore.sh webroot-deletes/webroot_file_list.dat.deleted.${machine_ip} ${HOME}/runtime/webroot_audit/deletes_aggregate

for file in `/bin/cat ${HOME}/runtime/webroot_audit/deletes_aggregate/*`
do
 /bin/rm ${file}
done

${HOME}/providerscripts/datastore/configwrapper/SyncWebrootToDatastore.sh
${HOME}/providerscripts/datastore/configwrapper/SyncDatastoreToWebroot.sh

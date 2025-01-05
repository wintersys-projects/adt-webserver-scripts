#set -x

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" != "1" ] )
then
        exit
fi

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"
invocation_time="${1}"

if ( [ ! -f ${HOME}/runtime/webroot_manifests ] )
then
  /bin/mkdir -p ${HOME}/runtime/webroot_manifests
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh failed_webroot_manifest/*-${machine_ip}`" != "" ] )
then
  ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh failed_webroot_manifest/*-${machine_ip} ${HOME}/runtime/webroot_manifests
fi

if ( [ "`/usr/bin/find /home/XvR5HynuvMeGekkK5LTX/runtime/webroot_manifests/ -name "*incoming*" -print`" != "" ] )
then
        /bin/cat ${HOME}/runtime/webroot_manifests/*incoming* > ${HOME}/runtime/webroot_manifests/aggregate_webroot_files
fi

for file_name in `/bin/cat ${HOME}/runtime/webroot_manifests/aggregate_webroot_files`
do
        youngest_epoch="`/bin/grep "${file_name}" ${HOME}/runtime/webroot_manifests/aggregate_webroot_files | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/sort -n | /usr/bin/tail -1`"
        chosen_manifest="`/bin/grep "${file_name}:${youngest_epoch}" ${HOME}/runtime/webroot_manifests/*incoming* | /usr/bin/awk -F':' '{print $1}'`"
        for manifest_file in "`/usr/bin/find /home/XvR5HynuvMeGekkK5LTX/runtime/webroot_manifests/ -name "*incoming*" -print`"
        do
                /bin/sed -i "/^${file_name}:/d" ${manifest_file}
        done
        /bin/echo "${file_name}:${youngest_epoch}" >> ${chosen_manifest}
done

machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

webserver_ips="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/* | /bin/sed "s/${machine_ip}//g" | /bin/sed 's/  / /g'`"

for webserver_ip in ${webserver_ips}
do
        for file in `/bin/cat ${HOME}/runtime/webroot_manifests/webroot_manifest_incoming-${webserver_ip}-${invocation_time} | /usr/bin/awk -F':' '{print $1}'`
        do
                /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -P ${SSH_PORT} ${file} ${SERVER_USER}@${webserver_ip}:${file}
                /usr/bin/sssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${SUDO} /bin/chmod 644 ${file};${SUDO} /bin/chown www-data:www-data ${file}"
        done
done


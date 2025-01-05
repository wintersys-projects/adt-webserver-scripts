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

if ( [ "`/usr/bin/find /home/XvR5HynuvMeGekkK5LTX/runtime/webroot_manifests/ -name "*incoming*-${invocation_time}" -print`" != "" ] )
then
        /bin/cat ${HOME}/runtime/webroot_manifests/*incoming* > ${HOME}/runtime/webroot_manifests/aggregate-manifests-invocation-${invocation_time}
fi

for file_name in `/bin/cat ${HOME}/runtime/webroot_manifests/aggregate-manifests-invocation-${invocation_time}`
do
        youngest_epoch="`/bin/grep "${file_name}" ${HOME}/runtime/webroot_manifests/aggregate-manifests-invocation-${invocation_time} | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/sort -n | /usr/bin/tail -1`"
        chosen_manifest="`/bin/grep "${file_name}:${youngest_epoch}" ${HOME}/runtime/webroot_manifests/*incoming* | /usr/bin/awk -F':' '{print $1}'`"
        for manifest_file in "`/usr/bin/find /home/XvR5HynuvMeGekkK5LTX/runtime/webroot_manifests/ -name "*incoming*-${invocation_time}" -print`"
        do
                /bin/sed -i "/^${file_name}:/d" ${manifest_file}
        done
        /bin/echo "${file_name}:${youngest_epoch}" >> ${chosen_manifest}
done

machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

webserver_ips="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/* | /bin/sed "s/${machine_ip}//g" | /bin/sed 's/  / /g'`"
updated_webroot="0"
for webserver_ip in ${webserver_ips}
do
        for file in `/bin/cat ${HOME}/runtime/webroot_manifests/webroot_manifest_incoming-${webserver_ip}-${invocation_time} | /usr/bin/awk -F':' '{print $1}'`
        do
                updated_webroot="1"
                path_to_file="`/usr/bin/readlink -f ${file} | /bin/sed 's:/[^/]*$::'`"
                if ( [ ! -d ${path_to_file} ] )
                then
                        /bin/mkdir -p ${path_to_file}
                fi
                /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -P ${SSH_PORT} ${SERVER_USER}@${webserver_ip}:${file} ${file}
                /bin/chmod 644 ${file}
                /bin/chown www-data:www-data ${file}
        done
        if ( [ "${updated_webroot}" = "1" ] )
        then
                ${HOME}/providerscripts/utilities/security/EnforcePermissions.sh
        fi
done


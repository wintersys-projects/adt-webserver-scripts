set -x

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "


 file_removed() {
         machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"
        webserver_ips="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/* | /bin/sed "s/${machine_ip}//g" | /bin/sed 's/  / /g'`"
        for webserver_ip in ${webserver_ips}
        do
                if ( [ "${webserver_ip}" != "${machine_ip}" ] )
                then
                  /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@10.0.0.6 "${CUSTOM_USER_SUDO} /usr/bin/rm ${1}${2}"
                fi
        done
}

file_modified() {
        machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"
        webserver_ips="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/* | /bin/sed "s/${machine_ip}//g" | /bin/sed 's/  / /g'`"
        for webserver_ip in ${webserver_ips}
        do
                if ( [ "${webserver_ip}" != "${machine_ip}" ] )
                then
                 /usr/bin/rsync -avz  -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /bin/mkdir -p ${1} && /usr/bin/sudo /usr/bin/rsync " ${1}${2} ${SERVER_USER}@${webserver_ip}:${1}${2}
                fi
        done
}

file_created() {
        machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"
        webserver_ips="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/* | /bin/sed "s/${machine_ip}//g" | /bin/sed 's/  / /g'`"
        for webserver_ip in ${webserver_ips}
        do
                if ( [ "${webserver_ip}" != "${machine_ip}" ] )
                then
                 /usr/bin/rsync -avz  -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /bin/mkdir -p ${1} && /usr/bin/sudo /usr/bin/rsync " ${1}${2} ${SERVER_USER}@${webserver_ip}:${1}${2}
 parent_directory="${1}"
                fi
        done
      
                 while ( [ "${parent_directory}" != "/var/www/html" ] )
                 do
                   /bin/chown www-data:www-data ${parent_directory}
                   /bin/chmod 755 ${parent_directory}
                   parent_directory="`/bin/echo ${parent_directory} | /bin/sed 's:/[^/]*$::'`"
                 done
}

/usr/bin/inotifywait -q -m -r -e modify,delete,create /var/www/html | while read DIRECTORY EVENT FILE; do
    case $EVENT in
        MODIFY*)
            file_modified "$DIRECTORY" "$FILE"
            ;;
        CREATE*)
            file_created "$DIRECTORY" "$FILE"
            ;;
        DELETE*)
            file_removed "$DIRECTORY" "$FILE"
            ;;
    esac
done

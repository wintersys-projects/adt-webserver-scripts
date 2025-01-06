
SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

 file_removed() {
        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f`"
        for webserver_ip in ${other_webserver_ips}
        do
                  /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@10.0.0.6 "${CUSTOM_USER_SUDO} /usr/bin/rm ${1}${2}"
        done
}

file_modified() {
        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f`"
        for webserver_ip in ${other_webserver_ips}
        do
                 /usr/bin/rsync -az -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /bin/mkdir -p ${1} 2>dev/null && /usr/bin/sudo /usr/bin/rsync " ${1}${2} ${SERVER_USER}@${webserver_ip}:${1}${2}
 parent_directory="${1}"
        done
         
         parent_directory="${1}"

         if ( [ "${parent_directory}" != "" ] )
         then
                 while ( [ "${parent_directory}" != "/var/www/html" ] )
                 do
                   /bin/chown www-data:www-data ${parent_directory}
                   /bin/chmod 755 ${parent_directory}
                   parent_directory="`/bin/echo ${parent_directory} | /bin/sed 's:/[^/]*$::'`"
                 done
         fi
}

file_created() {
        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f`"
        for webserver_ip in ${other_webserver_ips}
        do
                 /usr/bin/rsync -az -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /bin/mkdir -p ${1} 2>/dev/null && /usr/bin/sudo /usr/bin/rsync " ${1}${2} ${SERVER_USER}@${webserver_ip}:${1}${2}
 parent_directory="${1}"
        done

         parent_directory="${1}"

         if ( [ "${parent_directory}" != "" ] )
         then
                 while ( [ "${parent_directory}" != "/var/www/html" ] )
                 do
                   /bin/chown www-data:www-data ${parent_directory}
                   /bin/chmod 755 ${parent_directory}
                   parent_directory="`/bin/echo ${parent_directory} | /bin/sed 's:/[^/]*$::'`"
                 done
         fi
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

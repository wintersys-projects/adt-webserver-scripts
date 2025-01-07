set -x


if ( [ "`/usr/bin/ps -ef | /bin/grep 'inotify' | /bin/grep -v grep`" != "" ] )
then
        exit
else
#        ${HOME}/providerscripts/datastore/configwrapper/SyncWebrootConfigDatastore.sh
:

fi

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

 file_removed() {
        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"
        for webserver_ip in ${other_webserver_ips}
        do
                 /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /usr/bin/rm ${1}${2} || ${CUSTOM_USER_SUDO} /usr/bin/rmdir ${1}${2}" 2>/dev/null
        done 
}

file_updated() {
        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

        directory="${1}"
        file="${2}"

        for webserver_ip in ${other_webserver_ips}
        do
                if ( [ ! -d ${directory}${file} ] )
                then
                        /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /usr/bin/mkdir -p ${directory}" 
                        /usr/bin/rsync -az --checksum -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /usr/bin/rsync " ${directory}${file} ${SERVER_USER}@${webserver_ip}:${directory}${file}
                        /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/chown www-data:www-data ${directory}${file} ; ${CUSTOM_USER_SUDO} /bin/chmod 644 ${directory}${file}"
                        cropped_filename="`/bin/echo ${directory}${file} | /bin/sed 's,/var/www/html/,,g'`"
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${directory}${file} webroot-update/${cropped_filename} "no"
                fi
        done
         
         parent_directory="${1}"

         if ( [ "${parent_directory}" != "" ] )
         then
                /bin/chown www-data:www-data ${parent_directory}
                /bin/chmod 755 ${parent_directory}
                 while ( [ "${parent_directory}" != "/var/www/html" ] )
                 do
                   /bin/chown www-data:www-data ${parent_directory}
                   /bin/chmod 755 ${parent_directory}
                   parent_directory="`/bin/echo ${parent_directory} | /bin/sed 's:/[^/]*$::'`"
                 done
        fi
}

/usr/bin/inotifywait -q -m -r -e modify,delete,create --exclude '/\.[^/]*$' /var/www/html | while read DIRECTORY EVENT FILE; do

        echo "${DIRECTORY}" >> /tmp/file
        echo "${FILE}" >> /tmp/file
        echo "==========" >> /tmp/file
        if ( [ ! -d ${DIRECTORY}/${FILE} ] )
        then
            case $EVENT in
                MODIFY*)
                    file_updated "$DIRECTORY" "$FILE"
                    ;;
                CREATE*)
                    file_updated "$DIRECTORY" "$FILE" 
                    ;;
                DELETE*)
                    file_removed "$DIRECTORY" "$FILE" 
                    ;;
            esac
        fi
done

set -x


if ( [ "`/usr/bin/ps -ef | /bin/grep 'inotify' | /bin/grep -v grep`" != "" ] )
then
        exit
else
:
      #  ${HOME}/providerscripts/datastore/configwrapper/SyncWebrootConfigDatastore.sh
fi

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

 file_deleted() {
        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"
        for webserver_ip in ${other_webserver_ips}
        do
                 /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /usr/bin/rm ${1}${2} || ${CUSTOM_USER_SUDO} /usr/bin/rmdir ${1}${2}" 2>/dev/null
        done 
}

file_updated() {
        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

        file="${1}"
        directory="`/bin/echo ${file} | /bin/sed 's:/[^/]*$::'`"

        for webserver_ip in ${other_webserver_ips}
        do
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /usr/bin/mkdir -p ${directory}" 
                /usr/bin/rsync -az --checksum -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /usr/bin/rsync " ${file} ${SERVER_USER}@${webserver_ip}:${file}
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/chown www-data:www-data ${file} ; ${CUSTOM_USER_SUDO} /bin/chmod 644 ${file}"
                cropped_filename="`/bin/echo ${file} | /bin/sed 's,/var/www/html/,,g'`"
               # ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${file} webroot-update/${cropped_filename} "no"
        done
         
       #  parent_directories="${1}"

        # if ( [ "${parent_directories}" != "" ] )
         #then
         #       /bin/chown www-data:www-data ${parent_directories}
         #       /bin/chmod 755 ${parent_directories}
         #        while ( [ "${parent_directories}" != "/var/www/html" ] )
         #        do
         #          /bin/chown www-data:www-data ${parent_directories}
         #          /bin/chmod 755 ${parent_directories}
         #          parent_directories="`/bin/echo ${parent_directories} | /bin/sed 's:/[^/]*$::'`"
         #        done
        #fi
}

/usr/bin/inotifywait -q -m -r -e modify,delete,create --exclude '/\.[^/]*$' /var/www/html | /bin/egrep "(CREATE|MODIFY|DELETE)" | /usr/bin/awk '{print $1,$NF}' | /bin/sed 's/ //g' |
while read updated_file
do 
        if ( [ "`/bin/echo ${updated_file} | /bin/egrep "(CREATE|MODIFY)" | /bin/egrep -v "(DELETE|ISDIR)"`" != "" ] )
        then
                updated_file="`/bin/echo ${updated_file} | /usr/bin/awk '{print $1,$NF}'`"
        fi
        cropped_filename="`/bin/echo ${updated_file} | /bin/sed 's,/var/www/html/,,g'`"
        if ( [ "${cropped_filename}" != "${previous_filename}" ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${cropped_filename} webroot-update/${cropped_filename} "no" &
        fi
        previous_filename="${cropped_filename}"

      # file_updated ${updated_file} &
done

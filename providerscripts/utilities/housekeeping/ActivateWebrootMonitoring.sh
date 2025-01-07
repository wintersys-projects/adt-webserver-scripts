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
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${file} webroot-update/${cropped_filename} "no"
        done
         
         parent_directories="${1}"

         if ( [ "${parent_directories}" != "" ] )
         then
                /bin/chown www-data:www-data ${parent_directories}
                /bin/chmod 755 ${parent_directories}
                 while ( [ "${parent_directories}" != "/var/www/html" ] )
                 do
                   /bin/chown www-data:www-data ${parent_directories}
                   /bin/chmod 755 ${parent_directories}
                   parent_directories="`/bin/echo ${parent_directories} | /bin/sed 's:/[^/]*$::'`"
                 done
        fi
}

/usr/bin/inotifywait -q -m -r -e modify,delete,create,moved_to,moved_from --exclude '/\.[^/]*$' /var/www/html |
while read filesystem_activity
do 
        updated_file=`/bin/echo ${filesystem_activity} | /bin/egrep "(CREATE|MODIFY)" | /bin/grep -v "ISDIR" | /usr/bin/awk '{print $1,$3}' | /bin/sed 's/ //g'`
        if ( [ "${updated_file}" != "" ] )
        do
                file_updated ${updated_file}
        done
        
        deleted_file=`/bin/echo ${filesystem_activity} | /bin/grep "DELETE" | /bin/grep -v "ISDIR" | /usr/bin/awk '{print $1,$3}' | /bin/sed 's/ //g'`
        if ( [ "${deleted_file}" != "" ] )
        then
                file_deleted ${deleted_file}
        fi
done

#for deleted_file in ${deleted_files}
#do
#        file_removed ${deleted_file}
#done

#for updated_file in ${updated_files}
#do
#        file_updated ${updated_file}
#done

exit

#/usr/bin/inotifywait -q -m -r -e modify,delete,create --exclude '/\.[^/]*$' /var/www/html | while read DIRECTORY EVENT FILE; do
#
 #       echo "${DIRECTORY}" >> /tmp/file
  #      echo "${FILE}" >> /tmp/file
   #     echo "==========" >> /tmp/file
    #    if ( [ ! -d ${DIRECTORY}/${FILE} ] )
     #   then
      #      case $EVENT in
       #         MODIFY*)
#                    file_updated "$DIRECTORY" "$FILE"
 #                   ;;
  #              CREATE*)
  #                  file_updated "$DIRECTORY" "$FILE" 
   ##                 ;;
    #            DELETE*)
    #                file_removed "$DIRECTORY" "$FILE" 
   #                 ;;
    #        esac
    #    fi#
#done

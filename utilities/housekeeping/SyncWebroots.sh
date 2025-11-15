#!/bin/sh

#####rsync to an existing webserver --keep newer --delete if absent files when building a new machine that hasn't been FIRSTBUILD_INITIALISED yet
#####put merged_updates to datastore shared bucket and apply them to other regions
#####put deletes to a different datastore in a file and apply them to other regions - make the deletes timestamped for example 1230 1240 and keep the deletes
#####1201 1202 1203 1204 1205 1206 - check each one and apply from mutli-region transfer bucket and any file which is not 121 delete when its 1210 and any file that is not 122 delete when it is 1220 
######DIRECTORIES to miss
set -x

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
BUILD_IDENTIFIER="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"
config_file="`${HOME}/application/configuration/GetApplicationConfigFilename.sh`"

if ( [ ! -d ${HOME}/runtime/webroot_audit ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_audit
fi

for archive in `/usr/bin/find ${HOME}/runtime/webroot_audit -name "webroot_updates.*tar.gz"`
do
        /bin/tar xvfz ${archive} -C / --keep-newer-files
        if ( [ "$?" = "0" ] )
        then
                /bin/rm ${archive}
        fi
done

for deletes_list in `/usr/bin/find ${HOME}/runtime/webroot_audit -name "webroot_deletes.*"`
do
        for delete_list in ${deletes_list}
        do
                if ( [ -s ${delete_list} ] )
                then
                        for file in `/bin/cat ${delete_list}`
                        do
                                if ( [ -f ${file} ] )
                                then
                                        /bin/rm ${file}
                                elif ( [ -d ${file} ] )
                                then
                                        /bin/rm -r ${file}
                                fi
                        done
                fi
        done
        /bin/rm ${delete_list}
done

directories_to_miss=""

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        directories_to_miss="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
fi

if ( [ ! -d /var/www/html1 ] )
then
        /bin/mkdir /var/www/html1
        #/usr/bin/rsync -au ${rsync_exclusion_command} --exclude ${config_file} "/var/www/html/" "/var/www/html1"
        /usr/bin/rsync -au --exclude ${config_file} "/var/www/html/" "/var/www/html1"
        if ( [ "$?" = "0" ] )
        then
                /bin/touch ${HOME}/runtime/INITIAL_WEBROOT_SYNC_DONE
        else
                ${HOME}/providerscripts/email/SendEmail.sh "COULD NOT PERFORM INITIAL WEBROOT SYNC" "Syncing of webroots between machines won't work because the intial mirroring of the webroot on machine IP address {machine_ip} failed." "ERROR"
        fi
fi

diff_exclusion_commands=""

for directory in ${directories_to_miss}
do
        #       diff_exclusion_command=${diff_exclusion_command}" --exclude='/var/www/html/"${directory}"'"
        diff_exclusion_command=${diff_exclusion_command}" | /bin/grep -v /var/www/html/${directory} | /bin/grep -v /var/www/html1/${directory}"
done

eval '/usr/bin/diff --brief --exclude="'${config_file}'" --recursive /var/www/html /var/www/html1 | /bin/grep -E "(Only in|differ$)" | /bin/sed "s;: ;/;g"  '${diff_exclusion_command}'' > ${HOME}/runtime/webroot_audit/full_webroot_status_report.dat

/bin/grep "differ$" ${HOME}/runtime/webroot_audit/full_webroot_status_report.dat | /bin/grep -o ' .*/var/www/html.* ' | /usr/bin/awk '{print $1}' > ${HOME}/runtime/webroot_audit/modified_webroot_files.dat
/bin/grep "Only in" ${HOME}/runtime/webroot_audit/full_webroot_status_report.dat | /bin/sed 's/: //g' | /bin/grep -o "/var/www/html/.*" > ${HOME}/runtime/webroot_audit/added_webroot_files.dat
/bin/grep "Only in" ${HOME}/runtime/webroot_audit/full_webroot_status_report.dat | /bin/sed 's/: //g' | /bin/grep -o "/var/www/html1/.*" > ${HOME}/runtime/webroot_audit/deleted_webroot_files.dat


for file in `/bin/cat ${HOME}/runtime/webroot_audit/modified_webroot_files.dat`
do
        dest_file="`/bin/echo ${file} | /bin/sed 's;/html/;/html1/;g'`"
        parents="`/usr/bin/dirname ${dest_file}`"
        /bin/mkdir -p ${parents}
        /usr/bin/rsync ${file} ${dest_file}
done

for file in `/bin/cat ${HOME}/runtime/webroot_audit/added_webroot_files.dat`
do
        if ( [ -d ${file} ] )
        then
                /usr/bin/find ${file}  -name "*" -print | /bin/grep -v "${file}" >> ${HOME}/runtime/webroot_audit/added_webroot_files.dat.$$
        fi
        dest_file="`/bin/echo ${file} | /bin/sed 's;/html/;/html1/;g'`"
        parents="`/usr/bin/dirname ${dest_file}`"
        /bin/mkdir -p ${parents}
        /usr/bin/rsync ${file} ${dest_file}
done


if ( [ -f ${HOME}/runtime/webroot_audit/added_webroot_files.dat.$$ ] )
then
        for file in `/bin/cat ${HOME}/runtime/webroot_audit/added_webroot_files.dat.$$`
        do
                dest_file="`/bin/echo ${file} | /bin/sed 's;/html/;/html1/;g'`"
                parents="`/usr/bin/dirname ${dest_file}`"
                /bin/mkdir -p ${parents}
                /usr/bin/rsync ${file} ${dest_file}
        done
        /bin/cat ${HOME}/runtime/webroot_audit/added_webroot_files.dat.$$ >> ${HOME}/runtime/webroot_audit/added_webroot_files.dat
        /bin/rm ${HOME}/runtime/webroot_audit/added_webroot_files.dat.$$
fi

exit

for file in `/bin/cat ${HOME}/runtime/webroot_audit/deleted_webroot_files.dat`
do
        del_file="`/bin/echo ${file} | /bin/sed 's;/html/;/html1/;g'`"
        if ( [ -f ${del_file} ] )
        then
                /bin/rm ${del_file}
        elif ( [ -d ${del_file} ] )
        then
                /bin/rm -r ${del_file}
        fi
done


exit

/bin/cat ${HOME}/runtime/webroot_audit/modified_webroot_files.dat ${HOME}/runtime/webroot_audit/added_webroot_files.dat > ${HOME}/runtime/webroot_audit/merged_updates_webroot_files.dat

if ( [ -s ${HOME}/runtime/webroot_audit/merged_updates_webroot_files.dat ] )
then
        /usr/bin/tar cfzp ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz -T ${HOME}/runtime/webroot_audit/merged_updates_webroot_files.dat --owner=www-data --group=www-data
fi

if ( [ -s ${HOME}/runtime/webroot_audit/added_webroot_files.dat ] || [ -s ${HOME}/runtime/webroot_audit/modified_webroot_files.dat ] || [ -s ${HOME}/runtime/webroot_audit/deleted_webroot_files.dat ] )
then
        /bin/echo "" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
        /bin/echo "========================`/usr/bin/date`=================================" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
        /bin/echo "" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log

        if ( [ -s ${HOME}/runtime/webroot_audit/added_webroot_files.dat ] )
        then
                /bin/echo "added" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
                /bin/echo "--------" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
                /bin/cat ${HOME}/runtime/webroot_audit/added_webroot_files.dat >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
        fi

        if ( [ -s ${HOME}/runtime/webroot_audit/modified_webroot_files.dat ] )
        then
                /bin/echo "modified" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
                /bin/echo "--------" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
                /bin/cat ${HOME}/runtime/webroot_audit/modified_webroot_files.dat >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
        fi

        if ( [ -s ${HOME}/runtime/webroot_audit/deleted_webroot_files.dat ] )
        then
                /bin/echo "deleted" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
                /bin/echo "--------" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
                /bin/cat ${HOME}/runtime/webroot_audit/deleted_webroot_files.dat >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
        fi
fi

other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

for webserver_ip in ${other_webserver_ips}
do
        if ( [ -s ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz ] )
        then
                /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -P ${SSH_PORT} ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz ${SERVER_USER}@${webserver_ip}:/tmp/webroot_updates.${machine_ip}.tar.gz
                tar_archive="${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz"
                if ( [ -f ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz ] )
                then
                        tar_archive="${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.$$.tar.gz"
                fi

                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv  /tmp/webroot_updates.${machine_ip}.tar.gz ${tar_archive}"
        fi

        if ( [ -s ${HOME}/runtime/webroot_audit/deleted_webroot_files.dat ] )
        then
                /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -P ${SSH_PORT} ${HOME}/runtime/webroot_audit/deleted_webroot_files.dat ${SERVER_USER}@${webserver_ip}:/tmp/webroot_deletes.${machine_ip}
                deletes_file="${HOME}/runtime/webroot_audit/webroot_deletes.${machine_ip}"
                if ( [ -f ${HOME}/runtime/webroot_audit/webroot_deletes.${machine_ip} ] )
                then
                        deletes_file="${HOME}/runtime/webroot_audit/webroot_deletes.$$.${machine_ip}"
                fi
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv  /tmp/webroot_deletes.${machine_ip} ${deletes_file}"
        fi
done

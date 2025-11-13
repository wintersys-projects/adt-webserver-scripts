#!/bin/sh

#set -x

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
BUILD_IDENTIFIER="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"

CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

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

for deletes_list in `/usr/bin/find ${HOME}/runtime/webroot_audit -name ".*webroot_deletes.*"`
do
        for delete_list in ${deletes_list}
        do
                if ( [ -s ${delete_list} ] )
                then
                        for file in `/bin/cat ${delete_list}`
                        do
                                /bin/rm ${file}
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
        /usr/bin/rsync -au "/var/www/html/" "/var/www/html1"
fi

/usr/bin/diff --brief --exclude='.*' --exclude='images' /var/www/html /var/www/html1 | /bin/grep -E "(Only in|differ$)" > ${HOME}/runtime/webroot_audit/full_webroot_status_report.dat

/bin/grep "differ$" ${HOME}/runtime/webroot_audit/full_webroot_status_report.dat | /bin/grep -o ' .*/var/www/html.* ' | /usr/bin/awk '{print $1}' | /bin/sed 's;/var/www/html/;;' > ${HOME}/runtime/webroot_audit/modified_webroot_files.dat
/bin/grep "Only in" ${HOME}/runtime/webroot_audit/full_webroot_status_report.dat | /bin/grep -o '.*/var/www/html.*' | /bin/grep '/var/www/html:' | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/webroot_audit/added_webroot_files.dat
/bin/grep "Only in" ${HOME}/runtime/webroot_audit/full_webroot_status_report.dat | /bin/grep -o '.*/var/www/html1.*' | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/webroot_audit/deleted_webroot_files.dat


for file in `/bin/cat ${HOME}/runtime/webroot_audit/modified_webroot_files.dat`
do
        /bin/cp /var/www/html/${file} /var/www/html1/${file}
done

for file in `/bin/cat ${HOME}/runtime/webroot_audit/added_webroot_files.dat`
do
        /bin/cp /var/www/html/${file} /var/www/html1/${file}
done

for file in `/bin/cat ${HOME}/runtime/webroot_audit/deleted_webroot_files.dat`
do
        /bin/rm /var/www/html1/${file}
done

/bin/cat ${HOME}/runtime/webroot_audit/modified_webroot_files.dat ${HOME}/runtime/webroot_audit/added_webroot_files.dat > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates

if ( [ -s ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates ] )
then
        /usr/bin/tar cfzp ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz -T ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates --owner=www-data --group=www-data
fi

other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

for webserver_ip in ${other_webserver_ips}
do
        if ( [ -s ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz ] )
        then
                /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -P ${SSH_PORT} ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz ${SERVER_USER}@${webserver_ip}:/tmp/webroot_updates.${machine_ip}.tar.gz
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv  /tmp/webroot_updates.${machine_ip}.tar.gz ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz"
        fi

        if ( [ -s ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ] )
        then
                /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -P ${SSH_PORT} ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ${SERVER_USER}@${webserver_ip}:/tmp/webroot_deletes.${machine_ip}
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv  /tmp/webroot_deletes.${machine_ip} ${HOME}/runtime/webroot_audit/webroot_deletes.${machine_ip}"
        fi
done

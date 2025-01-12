export HOME=`/bin/cat /home/homedir.dat`

WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
TOKEN="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
configbucket="`/bin/echo "${WEBSITE_URL}"-config | /bin/sed 's/\./-/g'`-${TOKEN}"


${HOME}/providerscripts/utilities/housekeeping/AuditWebroot.sh

if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ] )
then
        echo "found deleted"
        /bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted

        for file in `/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted | /bin/sed 's,/var/www/html/,,g'`
        do
               ${HOME}/providerscripts/datastore/configwrapper/CopyFileConfigDatastore.sh webroot/${file} webroot/${file}-${SERVER_USER}-marker
               # ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webroot/${file}
        done
fi

if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat.added ] && [ "`/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.added`" != "" ] )
then
        for file in `/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.added`
        do
                if ( [ -f ${file} ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${file} webroot`/bin/echo ${file} | /bin/sed 's,/var/www/html,,g'`
                fi
        done
fi

${HOME}/providerscripts/datastore/configwrapper/SyncDatastoreWithWebroot.sh

if ( [ ! -d ${HOME}/runtime/webroot_audit/${SERVER_USER} ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_audit/${SERVER_USER}
else
        /bin/rm -r ${HOME}/runtime/webroot_audit/${SERVER_USER}/*
fi

other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

for s3_marker_file in `s3cmd sync --dry-run s3://${configbucket}/webroot/ ${HOME}/runtime/webroot_audit/${SERVER_USER}/ | /bin/grep ${SERVER_USER}-marker | /bin/grep download | /usr/bin/awk '{print $2}'`
do
        s3_marker_file="`/bin/echo ${s3_marker_file} | /bin/sed "s/'//g"`"

        s3cmd del ${s3_marker_file}
        real_file="`/bin/echo ${s3_marker_file} | /bin/sed "s/-${SERVER_USER}-marker*//g"`"
        s3cmd del ${real_file}

        local_marker_file="`/bin/echo ${s3_marker_file} | /bin/sed 's,.*webroot/,,g'`"
        real_local_file="`/bin/echo ${local_marker_file} | /bin/sed "s/-${SERVER_USER}-marker*//g"`"
        if ( [ -f /var/www/html/${local_marker_file} ] )
        then
                /bin/rm /var/www/html/${local_marker_file}
        fi
        if ( [ -f /var/www/html/${real_local_file} ] )
        then
                /bin/rm /var/www/html/${real_local_file}
        fi
        for webserver_ip in ${other_webserver_ips}
        do
                /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/rm /var/www/html/${real_local_file}  /var/www/html/${local_marker_file}"
        fi
done









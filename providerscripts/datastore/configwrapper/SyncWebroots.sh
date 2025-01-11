export HOME=`/bin/cat /home/homedir.dat`
SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

${HOME}/providerscripts/utilities/housekeeping/AuditWebroot.sh

if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ] )
then
        echo "found deleted"
        /bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted

        for file in `/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted | /bin/sed 's,/var/www/html/,,g'`
        do
               ${HOME}/providerscripts/datastore/configwrapper/CopyFileConfigDatastore.sh webroot/${file} webroot/${file}-${SERVER_USER}
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

${HOME}/providerscripts/datastore/configwrapper/SyncDatastoreToWebroot.sh

if ( [ ! -d ${HOME}/runtime/webroot_audit/${SERVER_USER} ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_audit/${SERVER_USER}
else
        /bin/rm -r ${HOME}/runtime/webroot_audit/${SERVER_USER}/*
fi

s3cmd sync --dry-run s3://crew-nuocial-uk-config-xn33/webroot/ ${HOME}/runtime/webroot_audit/${SERVER_USER}/ | /bin/grep ${SERVER_USER}



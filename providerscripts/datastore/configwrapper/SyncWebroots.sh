${HOME}/providerscripts/utilities/housekeeping/AuditWebroot.sh

if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ] )
then
        echo "found deleted"
        /bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted

        for file in `/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted | /bin/sed 's,/var/www/html/,,g'`
        do
                ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webroot/${file}
        done
fi

for file in `/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.added | /bin/sed 's,/var/www/html/,,g'`
do
 ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh webroot/${file}
done
/bin/sleep 10

${HOME}/providerscripts/datastore/configwrapper/SyncDatastoreToWebroot.sh



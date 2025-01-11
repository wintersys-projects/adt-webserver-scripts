${HOME}/providerscripts/utilities/housekeeping/AuditAndUpdateWebrootDeletes.sh

/bin/sleep 10
${HOME}/providerscripts/datastore/configwrapper/SyncWebrootToDatastore.sh

for file in `/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted`
do
 ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webroot/${file}
 /bin/rm ${file}
done

/bin/sleep 10
${HOME}/providerscripts/datastore/configwrapper/SyncDatastoreToWebroot.sh


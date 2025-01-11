${HOME}/providerscripts/utilities/housekeeping/AuditAndUpdateWebrootDeletes.sh

for file in `/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted`
do
 ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webroot/${file}
 /bin/rm ${file}
done
${HOME}/providerscripts/datastore/configwrapper/SyncDatastoreToWebroot.sh "skip"
${HOME}/providerscripts/datastore/configwrapper/SyncWebrootToDatastore.sh
for file in `/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted`
do
 ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webroot/${file}
 /bin/rm ${file}
done
${HOME}/providerscripts/datastore/configwrapper/SyncDatastoreToWebroot.sh


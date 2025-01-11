${HOME}/providerscripts/utilities/housekeeping/AuditAndUpdateWebroot.sh

for file in `/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted`
do
 ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webroot/${file}
done

for file in `/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted`
do
 ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh webroot/${file}
done
/bin/sleep 10

${HOME}/providerscripts/datastore/configwrapper/SyncDatastoreToWebroot.sh




if ( [ ! -d /var/lib/adt-config ] )
then
        /bin/mkdir /var/lib/adt-config
        ${HOME}/providerscripts/datastore/operations/SyncFromDatastore.sh "config" "root" "/var/lib/adt-config"
fi

while ( [ "`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "INSTALLED_SUCCESSFULLY"`" = "" ] )
do
        /bin/sleep 1
fi

${HOME}/providerscripts/datastore/operations/SyncFromDatastore.sh "config" "root" "/var/lib/adt-config"

while ( [ 1 ] )
do
  /bin/sleep 2 && ${HOME}/providerscripts/datastore/filesystems-sync/heavyweight/FileSystemsSyncingController.sh '2' '/var/lib/adt-config' 'config-sync' 
  /bin/sleep 15 && ${HOME}/providerscripts/datastore/filesystems-sync/heavyweight/FileSystemsSyncingController.sh '15' '/var/lib/adt-config' 'config-sync' 
  /bin/sleep 15 && ${HOME}/providerscripts/datastore/filesystems-sync/heavyweight/FileSystemsSyncingController.sh '30' '/var/lib/adt-config' 'config-sync' 
  /bin/sleep 15 && ${HOME}/providerscripts/datastore/filesystems-sync/heavyweight/FileSystemsSyncingController.sh '45' '/var/lib/adt-config' 'config-sync' 
done

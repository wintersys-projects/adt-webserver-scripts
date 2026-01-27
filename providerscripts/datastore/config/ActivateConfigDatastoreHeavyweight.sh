
while ( [ 1 ] )
do
  /bin/sleep 2 && ${HOME}/providerscripts/datastore/filesystems-sync/heavyweight/FileSystemsSyncingController.sh '2' '/var/lib/adt-config' 'config' 
  /bin/sleep 15 && ${HOME}/providerscripts/datastore/filesystems-sync/heavyweight/FileSystemsSyncingController.sh '15' '/var/lib/adt-config' 'config' 
  /bin/sleep 30 && ${HOME}/providerscripts/datastore/filesystems-sync/heavyweight/FileSystemsSyncingController.sh '30' '/var/lib/adt-config' 'config' 
  /bin/sleep 45 && ${HOME}/providerscripts/datastore/filesystems-sync/heavyweight/FileSystemsSyncingController.sh '45' '/var/lib/adt-config' 'config' 
done

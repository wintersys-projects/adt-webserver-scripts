#set -x

config_file="`${HOME}/application/configuration/GetApplicationConfigFilename.sh`"
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"
MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"

command_body=""
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
        do
                command_body="${command_body} --exclude '/"${dir}"' --include '/"${dir}"/'"
        done
fi

command_body="${command_body} --exclude '"${config_file}"'" 

if ( [ ! -d ${HOME}/runtime/webroot_sync/outgoing ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/outgoing
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/processed ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/processed
fi

if ( [ ! -d /var/www/html1 ] )
then
        /usr/bin/rsync -av ${command_body} /var/www/html/ /var/www/html1
else
        echo "added"
        for file in `/usr/bin/rsync -rv --checksum --ignore-times ${command_body} /var/www/html/ /var/www/html1 | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /bin/sed '/^$/d'`
        do
                /usr/bin/tar frp ${HOME}/runtime/webroot_sync/outgoing/additions.${machine_ip}.$$.tar.gz  /var/www/html/${file} --owner=www-data --group=www-data
                /usr/bin/rsync -a /var/www/html/${file} /var/www/html1/${file}
                /bin/chown www-data:www-data /var/www/html1/${file}
                /bin/chmod 644 /var/www/html1/${file}
        done
        echo "removed"
        for file in `/usr/bin/rsync -rv --checksum --ignore-times ${command_body} /var/www/html1/ /var/www/html | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /bin/sed '/^$/d'`
        do
                /usr/bin/tar frp ${HOME}/runtime/webroot_sync/outgoing/deletes.${machine_ip}.$$.tar.gz  /var/www/html1/${file} --owner=www-data --group=www-data
                /bin/rm /var/www/html1/${file}
        done
fi

if ( [ "${MULTI_REGION}" != "1" ] )
then
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/additions.${machine_ip}.$$.tar.gz ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/additions.${machine_ip}.$$.tar.gz webrootsync/additions "yes"
        fi
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletes.${machine_ip}.$$.tar.gz ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletes.${machine_ip}.$$.tar.gz webrootsync/deletions "yes"
        fi

        if ( [ ! -f ${HOME}/runtime/webroot_sync/incoming/${additions} ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh webrootsync/additions ${HOME}/runtime/webroot_sync/incoming
        fi

        for archive in `/bin/ls ${HOME}/runtime/webroot_sync/incoming`
        do
                if ( [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
                then
                        /bin/tar xvf ${HOME}/runtime/webroot_sync/incoming/${archive} -C / --keep-newer-files
                        /bin/touch ${HOME}/runtime/webroot_sync/processed/${archive}
                fi
        done

        #/bin/tar xvfz ${archive} -C / --keep-newer-files
fi


#  Create Bucket if it doesn't exist multiregion/webrootsync if MULTI_REGION=1 or configbucket/webrootsync if MULTI_REGION=0
#  PutToDatastore addition file and delete file to multiregion/webrootsync/additions and deletes to multiregion/webrootsync/deletes
# SyncFromDatastore down all additions and deletes from multiregion/webrootsync/additions and multiregion/webrootsync/deletes
# Apply the additions and the deletes if they are not already processed  to the local machine and copy the touch a file in the processed 
# directory with the same name as the synced file
# write script that runs daily puts a block on syncing and cleans out local directories and the datastore buckets call it "ResetWebrootSync"

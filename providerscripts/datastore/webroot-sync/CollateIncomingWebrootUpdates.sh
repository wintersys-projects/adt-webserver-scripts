MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

if ( [ "${MULTI_REGION}" != "1" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh webrootsync/additions ${HOME}/runtime/webroot_sync/incoming/additions
else
        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
        ${HOME}/providerscripts/datastore/SyncFromDatastore.sh ${multi_region_bucket}/webrootsync/additions ${HOME}/runtime/webroot_sync/incoming/additions
fi

for archive in `/bin/ls ${HOME}/runtime/webroot_sync/incoming/additions`
do
        if ( [ "`/bin/echo ${archive} | /bin/grep "${machine_ip}"`" = "" ] && [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
        then
                /bin/tar xzvfp ${HOME}/runtime/webroot_sync/incoming/additions/${archive} -C / --keep-newer-files
                for file in `/bin/tar tvf ${HOME}/runtime/webroot_sync/incoming/additions/${archive} | /usr/bin/awk '{print $NF}'`
                do
                        source_file="/${file}"
                        destination_file="`/bin/echo ${source_file} | /bin/sed 's;/html/;/html1/;'`"
                        if ( [ -f ${source_file} ] )
                        then
                                /usr/bin/rsync -ap --mkpath ${source_file} ${destination_file}
                                /bin/chown www-data:www-data ${destination_file}
                                /bin/chmod 644 ${destination_file}
                        fi
                done
                /bin/touch ${HOME}/runtime/webroot_sync/processed/${archive}
        fi
done

for archive in `/bin/ls ${HOME}/runtime/webroot_sync/incoming/deletions`
do
        if ( [ "`/bin/echo ${archive} | /bin/grep "${machine_ip}"`" = "" ] && [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
        then
                deletions="`/bin/tar tvf ${HOME}/runtime/webroot_sync/incoming/deletions/${archive} -C / --keep-newer-files | /usr/bin/awk '{print $NF}'`"
                directories=""
                for file in ${deletions}
                do
                        source_file="/${file}"
                        sync_file="`/bin/echo ${source_file} | /bin/sed 's;/html/;/html1/;'`"
                        if ( [ -f ${source_file} ] )
                        then
                                /bin/rm ${source_file}
                        fi
                        if ( [ -f ${sync_file} ] )
                        then
                                /bin/rm ${sync_file}
                        fi
                        if ( [ -d ${source_file} ] )
                        then
                                if ( [ "`/usr/bin/find ${source_file} -maxdepth 0 -empty -exec echo {} is empty. \; | /bin/grep 'is empty'`" != "" ] )
                                then
                                        /bin/rm -r ${source_file}
                                fi
                        fi
                        if ( [ -d ${sync_file} ] )
                        then
                                if ( [ "`/usr/bin/find ${sync_file} -maxdepth 0 -empty -exec echo {} is empty. \; | /bin/grep 'is empty'`" != "" ] )
                                then
                                        /bin/rm -r ${sync_file}
                                fi
                        fi
                done
                /bin/touch ${HOME}/runtime/webroot_sync/processed/${archive}
        fi
done


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
                /bin/tar xvfp ${HOME}/runtime/webroot_sync/incoming/additions/${archive} -C / --keep-newer-files
                for file in `/bin/tar tvf ${HOME}/runtime/webroot_sync/incoming/additions/${archive} | /usr/bin/awk '{print $NF}'`
                do
                        source_file="/${file}"
                        destination_file="`/bin/echo ${source_file} | /bin/sed 's;/html/;/html1/;'`"
                        if ( [ -f ${source_file} ] )
                        then
                                /usr/bin/sudo -u www-data /usr/bin/rsync -ap --mkpath ${source_file} ${destination_file}
                                /bin/chown www-data:www-data ${destination_file}
                                /bin/chmod 644 ${destination_file}
                        fi
                done
                /bin/touch ${HOME}/runtime/webroot_sync/processed/${archive}
        fi
done

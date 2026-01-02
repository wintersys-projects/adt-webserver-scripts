set -x

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

if ( [ "${MULTI_REGION}" != "1" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh webrootsync/historical/additions ${HOME}/runtime/webroot_sync/incoming/historical/additions
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh webrootsync/historical/deletions ${HOME}/runtime/webroot_sync/incoming/historical/deletions
else
        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
        ${HOME}/providerscripts/datastore/SyncFromDatastore.sh ${multi_region_bucket}/webrootsync/historical/additions ${HOME}/runtime/webroot_sync/incoming/historical/additions
        ${HOME}/providerscripts/datastore/SyncFromDatastore.sh ${multi_region_bucket}/webrootsync/historical/deletions ${HOME}/runtime/webroot_sync/incoming/historical/deletions
fi

for archive in `/bin/ls ${HOME}/runtime/webroot_sync/incoming/historical/deletions`
do
        if ( [ "`/bin/echo ${archive} | /bin/grep "${machine_ip}"`" = "" ] && [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
        then
                for file in `/bin/cat ${HOME}/runtime/webroot_sync/incoming/historical/deletions/${archive}`
                do
                        if ( [ -f ${file} ] )
                        then
                                /bin/rm ${file}
                        fi
                        if ( [ -d ${file} ] && [ "`/usr/bin/find ${file} -maxdepth 0 -empty -exec echo {} is empty. \; | /bin/grep 'is empty'`" != "" ] )
                        then
                                /bin/rm -r ${file}
                        fi
                done
                /bin/touch ${HOME}/runtime/webroot_sync/processed/${archive}
        fi
        /usr/bin/find /var/www/html -type d -empty -delete
        /usr/bin/find /var/www/html1 -type d -empty -delete
done

for archive in `/bin/ls ${HOME}/runtime/webroot_sync/incoming/historical/additions`
do
        if ( [ "`/bin/echo ${archive} | /bin/grep "${machine_ip}"`" = "" ] && [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
        then
                /bin/tar xvfpz ${HOME}/runtime/webroot_sync/incoming/historical/additions/${archive} -C / --keep-newer-files --same-owner --same-permissions
                root_dirs="`/bin/tar tvfpz ${HOME}/runtime/webroot_sync/incoming/historical/additions/${archive} | /usr/bin/awk -F'/' '{print $5}' | /usr/bin/uniq`"
                for root_dir in ${root_dirs}
                do
                        /bin/chown -R www-data:www-data /var/www/html/${root_dir}
                        /bin/chown -R www-data:www-data /var/www/html1/${root_dir}
                        /usr/bin/find /var/www/html/${root_dir} -type d -exec chmod 755 {} + 
                        /usr/bin/find /var/www/html1/${root_dir} -type d -exec chmod 755 {} + 
                        /usr/bin/find /var/www/html/${root_dir} -type f -exec chmod 644 {} + 
                        /usr/bin/find /var/www/html1/${root_dir} -type f -exec chmod 644 {} +  
                done
                
                
                /bin/touch ${HOME}/runtime/webroot_sync/processed/${archive}
        fi
done



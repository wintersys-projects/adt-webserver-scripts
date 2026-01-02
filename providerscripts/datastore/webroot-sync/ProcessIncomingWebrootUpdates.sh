set -x

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

if ( [ "${MULTI_REGION}" != "1" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh webrootsync/additions ${HOME}/runtime/webroot_sync/incoming/additions
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh webrootsync/deletions ${HOME}/runtime/webroot_sync/incoming/deletions
else
        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
        ${HOME}/providerscripts/datastore/SyncFromDatastore.sh ${multi_region_bucket}/webrootsync/additions ${HOME}/runtime/webroot_sync/incoming/additions
        ${HOME}/providerscripts/datastore/SyncFromDatastore.sh ${multi_region_bucket}/webrootsync/deletions ${HOME}/runtime/webroot_sync/incoming/deletions
fi



for archive in `/bin/ls ${HOME}/runtime/webroot_sync/incoming/additions`
do
        if ( [ "`/bin/echo ${archive} | /bin/grep "${machine_ip}"`" = "" ] && [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
        then
                /bin/tar xvfpz ${HOME}/runtime/webroot_sync/incoming/additions/${archive} -C / --keep-newer-files --owner=www-data --group=www-data
                /bin/touch ${HOME}/runtime/webroot_sync/processed/${archive}
        fi
done

for archive in `/bin/ls ${HOME}/runtime/webroot_sync/incoming/deletions`
do
        if ( [ "`/bin/echo ${archive} | /bin/grep "${machine_ip}"`" = "" ] && [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
        then
                for file in `/bin/cat ${HOME}/runtime/webroot_sync/incoming/deletions/${archive}`
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

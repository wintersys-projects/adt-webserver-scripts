MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

for expired_deletion_archive in `/usr/bin/find ${HOME}/runtime/webroot_sync/processing -type f -mmin +5 | /bin/grep 'deletions' | /usr/bin/awk -F'/' '{print $NF}'`
do
        if ( [ -f ${HOME}/runtime/webroot_sync/processing/${expired_deletion_archive} ] )
        then
                /bin/rm ${HOME}/runtime/webroot_sync/processing/${expired_deletion_archive}
        fi

        if ( [ -f ${HOME}/runtime/webroot_sync/incoming/deletions/${expired_deletion_archive} ] )
        then
                /bin/rm ${HOME}/runtime/webroot_sync/incoming/deletions/${expired_deletion_archive}
        fi
        
        if ( [ "${MULTI_REGION}" != "1" ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webrootsync/deletions/${expired_deletion_archive}
        else
                multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
                ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${multi_region_bucket}/webrootsync/deletions/${expired_deletion_archive}
        fi
done

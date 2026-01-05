set -x

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"
additions_present="0"
deletions_present="0"

if ( [ "${MULTI_REGION}" != "1" ] )
then
        if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsync/additions/additions*.tar.gz 2>/dev/null`" != "" ] )
        then
                additions_present="1"
        fi

        if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsync/deletions/deletions*.log 2>/dev/null`" != "" ] )
        then
                deletions_present="1"
        fi
        if ( [ "${additions_present}" = "1" ] )
        then
                additions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsync/additions/additions*.tar.gz 2>/dev/null`"
                for addition in ${additions}
                do
                        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh webrootsync/additions/${addition} ${HOME}/runtime/webroot_sync/incoming/additions
                done
        fi
        if ( [ "${deletions_present}" = "1" ] )
        then
                deletions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsync/deletions/deletions*.log 2>/dev/null`"
                for deletion in ${deletions}
                do
                        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh webrootsync/deletions/${deletion} ${HOME}/runtime/webroot_sync/incoming/deletions
                done
        fi
else
        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
        if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${multi_region_bucket}/webrootsync/additions/additions*.tar.gz 2>/dev/null`" != "" ] )
        then
                additions_present="1"
        fi
        if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${multi_region_bucket}/webrootsync/deletions/deletions*.log 2>/dev/null`" != "" ] )
        then
                deletions_present="1"
        fi

        if ( [ "${additions_present}" = "1" ] )
        then
                additions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${multi_region_bucket}/webrootsync/additions/additions*.tar.gz 2>/dev/null`"
                for addition in ${additions}
                do
                        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ${multi_region_bucket}/webrootsync/additions/${addition} ${HOME}/runtime/webroot_sync/incoming/additions
                done
        fi
        if ( [ "${deletions_present}" = "1" ] )
        then
                deletions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${multi_region_bucket}/webrootsync/deletions/deletions*.log 2>/dev/null`"
                for deletion in ${deletions}
                do
                        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ${multi_region_bucket}/webrootsync/deletions/${deletion} ${HOME}/runtime/webroot_sync/incoming/deletions
                done
        fi
fi

if ( [ "${deletions_present}" = "1" ] )
then
        archives="`/bin/ls ${HOME}/runtime/webroot_sync/incoming/deletions`"
        audit_header="not done"
        for archive in ${archives}
        do
                if ( [ "`/bin/echo ${archive} | /bin/grep "${machine_ip}"`" = "" ] && [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
                then
                        if ( [ "${audit_header}" = "not done" ] )
                        then
                                /bin/echo "======================================================================"  >> ${HOME}/runtime/webroot_sync/audit/deletions.log
                                /bin/echo "FILES REMOVED THIS TIME  (`/usr/bin/date`)" >> ${HOME}/runtime/webroot_sync/audit/deletions.log
                                /bin/echo "======================================================================"  >> ${HOME}/runtime/webroot_sync/audit/deletions.log
                                /bin/echo "" >> ${HOME}/runtime/webroot_sync/audit/deletions.log
                                audit_header="done"
                        fi
                        /bin/echo "Removed files from this machine's webroot from archive: ${archive}" >> ${HOME}/runtime/webroot_sync/audit/deletions.log
                        /bin/echo "" >> ${HOME}/runtime/webroot_sync/audit/deletions.log
                        /bin/cat ${HOME}/runtime/webroot_sync/incoming/deletions/${archive} >> ${HOME}/runtime/webroot_sync/audit/deletions.log
                        
                        /usr/bin/xargs rm < ${HOME}/runtime/webroot_sync/incoming/deletions/${archive}
                        if ( [ "$?" != "0" ] )
                        then
                                for file in `/bin/cat ${HOME}/runtime/webroot_sync/incoming/deletions/${archive}`
                                do
                                        /bin/rm ${file} 2>/dev/null
                                done
                        fi
                fi
                /bin/touch ${HOME}/runtime/webroot_sync/processed/${archive}
                /bin/touch ${HOME}/runtime/webroot_sync/processed/historical/${archive}

        done
        /usr/bin/find /var/www/html -type d -empty -delete
        /usr/bin/find /var/www/html1 -type d -empty -delete
fi

if ( [ "${additions_present}" = "1" ] )
then
        archives="`/bin/ls ${HOME}/runtime/webroot_sync/incoming/additions`"
        audit_header="not done"
        for archive in ${archives}
        do
                if ( [ "`/bin/echo ${archive} | /bin/grep "${machine_ip}"`" = "" ] && [ ! -f ${HOME}/runtime/webroot_sync/processed/${archive} ] )
                then
                        if ( [ "${audit_header}" = "not done" ] )
                        then
                                /bin/echo "======================================================================"  >> ${HOME}/runtime/webroot_sync/audit/additions.log
                                /bin/echo "FILES ADDED THIS TIME  (`/usr/bin/date`)" >> ${HOME}/runtime/webroot_sync/audit/additions.log
                                /bin/echo "======================================================================"  >> ${HOME}/runtime/webroot_sync/audit/additions.log
                                /bin/echo "" >> ${HOME}/runtime/webroot_sync/audit/additions.log
                                audit_header="done"
                        fi
                        /bin/echo "Added files to this machine's webroot from archive ${archive}" >> ${HOME}/runtime/webroot_sync/audit/additions.log
                        /bin/echo "" >> ${HOME}/runtime/webroot_sync/audit/additions.log
                        /bin/tar tvfz ${HOME}/runtime/webroot_sync/incoming/additions/${archive}  | /bin/sed 's:var/www/html:/var/www/html:g' >> ${HOME}/runtime/webroot_sync/audit/additions.log
                        /bin/tar xvfpz ${HOME}/runtime/webroot_sync/incoming/additions/${archive} -C / --keep-newer-files --same-owner --same-permissions
                        root_dirs="`/bin/tar tvfpz ${HOME}/runtime/webroot_sync/incoming/additions/${archive} | /usr/bin/awk -F'/' '{print $5}' | /usr/bin/uniq`"
                        for root_dir in ${root_dirs}
                        do
                                /bin/chown -R www-data:www-data /var/www/html/${root_dir}
                                /bin/chown -R www-data:www-data /var/www/html1/${root_dir}
                                /usr/bin/find /var/www/html/${root_dir} -type d -exec chmod 755 {} + 
                                /usr/bin/find /var/www/html1/${root_dir} -type d -exec chmod 755 {} + 
                                /usr/bin/find /var/www/html/${root_dir} -type f -exec chmod 644 {} + 
                                /usr/bin/find /var/www/html1/${root_dir} -type f -exec chmod 644 {} +  
                        done
                fi
                /bin/touch ${HOME}/runtime/webroot_sync/processed/${archive}
        done
fi



set -x
exclude_list=`${HOME}/application/configuration/GetApplicationConfigFilename.sh`

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
        do
                exclude_list="${exclude_list}$|${dir}"
        done
fi

additions=`cd /var/www/html ; /usr/bin/find . -depth -type f | /bin/grep -Ev "(${exclude_list})" | /usr/bin/cpio -pdmv /var/www/html1 2>&1 | /bin/grep -v "not created: newer or same age version exists"`

if ( [ ! -f ${HOME}/runtime/webroot_sync/SYNCING_INITIALISED ] )
then
        /bin/touch ${HOME}/runtime/webroot_sync/SYNCING_INITIALISED 
        exit
fi

for file in ${additions}
do
        /usr/bin/tar ufp ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar.gz  /var/www/html/${file} --owner=www-data --group=www-data

done 

config_file="`${HOME}/application/configuration/GetApplicationConfigFilename.sh`"
deletes=`/usr/bin/rsync --dry-run -vr ${command_body} --delete /var/www/html1/ /var/www/html | /usr/bin/head -n +3 | /usr/bin/tail -n +2 | /bin/sed '/^$/d' | /bin/grep -Ev "(${exclude_list})"`

full_path_deletes=""
for file in ${deletes}
do
        full_path_deletes="${full_path_deletes} /var/www/html/${file}"
done

for file in ${full_path_deletes}
do
        /bin/echo ${file} >>  ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log
        sync_file="`/bin/echo ${file} | /bin/sed 's;/html/;/html1'`"
        /bin/rm ${sync_file}
        /bin/echo "${sync_file}" >> ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log
done

if ( [ "${MULTI_REGION}" != "1" ] )
then
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar webrootsync/additions "yes"
        fi
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log webrootsync/deletions "yes"
        fi
else
        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar ${multi_region_bucket}/webrootsync/additions "yes"
        fi
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log ${multi_region_bucket}/webrootsync/deletions "yes"
        fi
fi


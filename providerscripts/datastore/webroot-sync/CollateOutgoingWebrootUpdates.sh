#set -x
exclude_list=`${HOME}/application/configuration/GetApplicationConfigFilename.sh`
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
        do
                exclude_list="${exclude_list}$|${dir}"
        done
        exclude_list="`/bin/echo ${exclude_list} | /bin/sed 's/|$//g'`"
fi

exclude_command=""
if ( [ "${exclude_list}" != "" ] )
then
        exclude_command=" /bin/grep -Evw '("
        for exclude_element in ${exclude_list}
        do
                exclude_command=" ${exclude_command}^${exclude_element}|"
        done
        exclude_command="`/bin/echo ${exclude_command} | /bin/sed 's/|$//'`"
        exclude_command="${exclude_command})' "
fi

first_run="0"
if ( [ ! -d /var/www/html1 ] )
then
        first_run="1"
fi

additions=`cd /var/www/html ; /usr/bin/find . -depth -type f | ${exclude_command} | /usr/bin/cpio -pdmv /var/www/html1 2>&1 | /bin/grep -v "not created: newer or same age version exists"`
additions="`/bin/echo ${additions} | /usr/bin/awk 'NF-=2' | /bin/sed 's;/\./;/;g'`"

if ( [ "${first_run}" = "1" ] )
then
        exit
fi

for file in ${additions}
do
        /usr/bin/tar ufp ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar  ${file} --owner=www-data --group=www-data
done 

synced_additions="`/bin/echo ${additions} | /bin/sed 's;/html1/;/html/;'`"

for file in ${synced_additions}
do
        /usr/bin/tar ufp ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar  ${file} --owner=www-data --group=www-data
done 

deletes_command=`/usr/bin/rsync --dry-run -vr /var/www/html1/ /var/www/html 2>&1 | /bin/sed '/^$/d' | /usr/bin/tail -n +2 | /usr/bin/head -n -3`
deletes_command='/bin/echo "'${deletes_command}'" | /usr/bin/tr " " "\\n" | '${exclude_command}

deletes=`eval ${deletes_command}`

full_path_deletes=""
for file in ${deletes}
do
        full_path_deletes="${full_path_deletes} /var/www/html/${file}"
done

for file in ${full_path_deletes}
do
        /bin/echo ${file} >>  ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log
        sync_file="`/bin/echo ${file} | /bin/sed 's;/html/;/html1/;'`"
        /bin/rm ${sync_file}
        /bin/echo "${sync_file}" >> ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log
done

cat ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log

if ( [ "${MULTI_REGION}" != "1" ] )
then
        rnd="`/usr/bin/shuf -i1-100 -n1`"
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/additions/additions.${machine_ip}.$$.tar webrootsync/additions "no"
                /bin/mv ${HOME}/runtime/webroot_sync/additions/additions.${machine_ip}.$$.tar ${HOME}/runtime/webroot_sync/additions/additions.${machine_ip}.$$.${rnd}.tar
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/additions/additions.${machine_ip}.$$.${rnd}.tar webrootsync/historical/additions "yes"
        fi
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/deletions/deletions.${machine_ip}.$$.log webrootsync/deletions "no"
                /bin/mv ${HOME}/runtime/webroot_sync/deletions/deletions.${machine_ip}.$$.tar ${HOME}/runtime/webroot_sync/deletions/deletions.${machine_ip}.$$.${rnd}.log
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/deletions/deletions.${machine_ip}.$$.${rnd}.log webrootsync/historical/deletions "yes"
        fi
else
        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
        rnd="`/usr/bin/shuf -i1-100 -n1`"
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToDatastore.sh  ${HOME}/runtime/webroot_sync/additions/additions.${machine_ip}.$$.tar ${multi_region_bucket}/webrootsync/additions "no"
                /bin/mv ${HOME}/runtime/webroot_sync/additions/additions.${machine_ip}.$$.tar ${HOME}/runtime/webroot_sync/additions/additions.${machine_ip}.$$.${rnd}.tar
                ${HOME}/providerscripts/datastore/configwrapper/PutToDatastore.sh  ${HOME}/runtime/webroot_sync/additions/additions.${machine_ip}.$$.${rnd}.tar ${multi_region_bucket}/webrootsync/historical/additions "yes"
        fi
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletions.${machine_ip}.$$.log ${multi_region_bucket}/webrootsync/deletions "yes"
                /bin/mv ${HOME}/runtime/webroot_sync/deletions/deletions.${machine_ip}.$$.tar ${HOME}/runtime/webroot_sync/deletions/deletions.${machine_ip}.$$.${rnd}.log
                ${HOME}/providerscripts/datastore/configwrapper/PutToDatastore.sh  ${HOME}/runtime/webroot_sync/deletions/deletions.${machine_ip}.$$.${rnd}.log ${multi_region_bucket}/webrootsync/historical/deletions "no"
        fi
fi



config_file="`${HOME}/application/configuration/GetApplicationConfigFilename.sh`"
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"
MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

command_body=""

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
        do
                command_body="${command_body} --exclude '/"${dir}"' --include '/"${dir}"/'"
        done
fi

command_body="${command_body} --exclude '"${config_file}"'" 
        
#for file in `/usr/bin/rsync -av --dry-run --checksum --ignore-times ${command_body} /var/www/html1/ /var/www/html | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /bin/sed '/^$/d'`
for file in `/usr/bin/rsync -rvnc --delete /var/www/html1/ /var/www/html | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /bin/sed '/^$/d'`
do
       # /usr/bin/tar frp ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.tar  /var/www/html1/${file} --owner=www-data --group=www-data
        /usr/bin/tar cfp ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.tar  -T /var/www/html1/${file} --owner=www-data --group=www-data
        if ( [ -f /var/www/html1/${file} ] )
        then
                /bin/rm /var/www/html1/${file}
        elif ( [ -d /var/www/html1/${file} ] )
        then
                /bin/rm -r /var/www/html1/${file}
        fi
done

if ( [ "${MULTI_REGION}" != "1" ] )
then
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.tar ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.tar webrootsync/deletions "yes"
        fi
else
        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"

        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.tar ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/PutToDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.tar ${multi_region_bucket}/webrootsync/deletions "yes"
        fi
fi

config_file="`${HOME}/application/configuration/GetApplicationConfigFilename.sh`"
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

command_body=""
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
        do
                command_body="${command_body} --exclude '/"${dir}"' --include '/"${dir}"/'"
        done
fi

command_body="${command_body} --exclude '"${config_file}"'" 


if ( [ ! -d /var/www/html1 ] )
then
        /usr/bin/rsync -av ${command_body} /var/www/html/ /var/www/html1
else
        echo "added"
        for file in `/usr/bin/rsync -rv --checksum --ignore-times ${command_body} /var/www/html/ /var/www/html1 | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /bin/sed '/^$/d'`
        do
                /usr/bin/tar frp ./updates.${machine_ip}.$$.tar.gz  /var/www/html/${file} --owner=www-data --group=www-data
        done
        echo "removed"
        for file in `/usr/bin/rsync -rv --checksum --ignore-times ${command_body} /var/www/html1/ /var/www/html | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /bin/sed '/^$/d'`
        do
                /usr/bin/tar frp ./deletes.${machine_ip}.$$.tar.gz  /var/www/html1/${file} --owner=www-data --group=www-data
        done
fi

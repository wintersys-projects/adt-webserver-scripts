command_body=""

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
        do
                command_body="${command_body} --exclude '/"${dir}"' --include '/"${dir}"/'"
        done
fi

command_body="${command_body} --exclude '"${config_file}"'" 

for file in `/usr/bin/rsync -rv --checksum --ignore-times ${command_body} /var/www/html/ /var/www/html1 | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /bin/sed '/^$/d'`
do
        if ( [ -f /var/www/html/${file} ] )
        then
                /usr/bin/tar frp ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar.gz  /var/www/html/${file} --owner=www-data --group=www-data
        fi
        /usr/bin/sudo -u www-data /usr/bin/rsync -ap --mkpath /var/www/html/${file} /var/www/html1/${file}
        /bin/chown www-data:www-data /var/www/html1/${file}
        /bin/chmod 644 /var/www/html1/${file}
done

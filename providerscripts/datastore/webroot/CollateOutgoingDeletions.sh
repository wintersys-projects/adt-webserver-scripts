        for file in `/usr/bin/rsync -rv --checksum --ignore-times ${command_body} /var/www/html1/ /var/www/html | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /bin/sed '/^$/d'`
        do
                /usr/bin/tar frp ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.tar.gz  /var/www/html1/${file} --owner=www-data --group=www-data
                if ( [ -f /var/www/html1/${file} ] )
                then
                        /bin/rm /var/www/html1/${file}
                elif ( [ -d /var/www/html1/${file} ] )
                then
                        /bin/rm -r /var/www/html1/${file}
                fi
        done

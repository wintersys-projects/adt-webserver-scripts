${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "" /var/lib/adt-config.$$

if ( [ -d /var/lib/adt-config1 ] )
then
        additions_command='cd /var/lib/adt-config.$$ ; /usr/bin/rsync -ri --dry-run --ignore-existing '${exclude_command}' /var/lib/adt-config.$$/ /var/www/adt-config1/ | /usr/bin/cut -d" " -f2 | /bin/sed -e "s;^;\./;g" -e "/.*\/$/d" | /usr/bin/cpio -pdmvu /var/lib/adt-config1 2>&1 | /bin/grep "^/var" | /bin/sed "s;/var/www/html1/;;g" | /usr/bin/tr " " "\\n"'
        modifieds_command='cd /var/lib/adt-config.$$ ; /usr/bin/rsync -ri --dry-run --checksum '${exclude_command}' /var/lib/adt-config.$$/ /var/lib/adt-config1/ | /usr/bin/cut -d" " -f2 | /bin/sed -e "s;^;\./;g" -e  "/.*\/$/d" | /usr/bin/cpio -pdmvu /var/lib/adt-config1 2>&1 | /bin/grep "^/var" | /bin/sed "s;/var/www/html1/;;g" | /usr/bin/tr " " "\\n"'
        additions=""
        additions=`eval ${additions_command}`
        modifieds=`eval ${modifieds_command}`
        additions="${additions} ${modifieds}"
        if ( [ "${additions}" != "" ] )
        then
                for addition in ${additions}
                do
                        /usr/bin/rsync -a /var/lib/adt-config.$$/${addition} /var/lib/config1/${addition}
                done
        fi
        
fi

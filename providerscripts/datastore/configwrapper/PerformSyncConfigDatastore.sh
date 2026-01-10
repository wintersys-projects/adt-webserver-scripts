#!/bin/sh
set -x
if ( [ -d /var/lib/adt-config1 ] )
then
        deletes_command='/usr/bin/rsync --dry-run -vr --ignore-existing /var/lib/adt-config1/ /var/lib/adt-config 2>&1 | /bin/sed -e "/^$/d" -e  "/.*\/$/d" | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /usr/bin/tr " " "\\n" '
        deletes=`eval ${deletes_command}`
        ${HOME}/providerscripts/datastore/configwrapper/SyncToConfigDatastore.sh /var/lib/adt-config/

        additions_command='cd /var/www/html ; /usr/bin/rsync -ri --dry-run --ignore-existing '${exclude_command}' /var/lib/adt-config/ /var/www/adt-config1/ | /usr/bin/cut -d" " -f2 | /bin/sed -e "s;^;\./;g" -e "/.*\/$/d" | /usr/bin/cpio -pdmvu /var/lib/adt-config1 2>&1 | /bin/grep "^/var" | /bin/sed "s;/var/www/html1/;;g" | /usr/bin/tr " " "\\n"'
        modifieds_command='cd /var/www/html ; /usr/bin/rsync -ri --dry-run --checksum '${exclude_command}' /var/lib/adt-config/ /var/lib/adt-config1/ | /usr/bin/cut -d" " -f2 | /bin/sed -e "s;^;\./;g" -e  "/.*\/$/d" | /usr/bin/cpio -pdmvu /var/lib/adt-config1 2>&1 | /bin/grep "^/var" | /bin/sed "s;/var/www/html1/;;g" | /usr/bin/tr " " "\\n"'
        additions=""
        additions=`eval ${additions_command}`
        modifieds=`eval ${modifieds_command}`
        additions="${additions} ${modifieds}"
        
fi

if ( [ "${deletes}" != "" ] )
then
        for file in ${deletes}
        do
                if ( [ -f /var/lib/adt-config1/${file} ] )
                then
                        /bin/rm /var/lib/adt-config1/${file}
                fi
                ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh ${file}
        done
fi

if ( [ -d /var/lib/adt-config1 ] )
then
        additions_command='cd /var/www/html ; /usr/bin/rsync -ri --dry-run --ignore-existing '${exclude_command}' /var/lib/adt-config/ /var/www/adt-config1/ | /usr/bin/cut -d" " -f2 | /bin/sed -e "s;^;\./;g" -e "/.*\/$/d" | /usr/bin/cpio -pdmvu /var/lib/adt-config1 2>&1 | /bin/grep "^/var" | /bin/sed "s;/var/www/html1/;;g" | /usr/bin/tr " " "\\n"'
        modifieds_command='cd /var/www/html ; /usr/bin/rsync -ri --dry-run --checksum '${exclude_command}' /var/lib/adt-config/ /var/lib/adt-config1/ | /usr/bin/cut -d" " -f2 | /bin/sed -e "s;^;\./;g" -e  "/.*\/$/d" | /usr/bin/cpio -pdmvu /var/lib/adt-config1 2>&1 | /bin/grep "^/var" | /bin/sed "s;/var/www/html1/;;g" | /usr/bin/tr " " "\\n"'
        additions=""
        additions=`eval ${additions_command}`
        modifieds=`eval ${modifieds_command}`
        additions="${additions} ${modifieds}"
        
fi

${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "" /var/lib/adt-config.$$

additions_command='cd /var/www/html ; /usr/bin/rsync -ri --dry-run --checksum '${exclude_command}' /var/lib/adt-config1/ /var/www/adt-config1.$$/'
eval `additions_command`

if ( [ -d /var/lib/adt-config ] )
then
        /bin/mv /var/lib/adt-config /var/lib/adt-config.old
fi
/bin/mv /var/lib/adt-config.$$ /var/lib/adt-config

if ( [ -d /var/lib/adt-config.old ] )
then
        /bin/rm -r /var/lib/adt-config.old
fi

if ( [ ! -d /var/lib/adt-config1 ] )
then
        /bin/mkdir -p /var/lib/adt-config1
        /bin/cp -r /var/lib/adt-config/* /var/lib/adt-config1/
fi



#!/bin/sh
#set -x

if ( [ -d /var/lib/adt-config1 ] )
then
        deletes_command='/usr/bin/rsync --dry-run -vr --exclude 'additions' --exclude 'deletions' --exclude 'webrootsync' /var/lib/adt-config1/ /var/lib/adt-config 2>&1 | /bin/sed -e "/^$/d" -e  "/.*\/$/d" | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /usr/bin/tr " " "\\n" '
        deletes=`eval ${deletes_command}`
        if ( [ "${deletes}" != "" ] )
        then
                for delete in ${deletes}
                do
                        place_to_put="`/bin/echo ${delete} | /bin/sed 's:/[^/]*$::'`"
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/lib/adt-config/${delete} deletions/${place_to_put} "no"
                done
        fi

        additions_command='cd /var/lib/adt-config ; /usr/bin/rsync -ri --dry-run --ignore-existing --exclude 'additions' --exclude 'deletions' --exclude 'webrootsync' /var/lib/adt-config/ /var/lib/adt-config1/ | /usr/bin/cut -d" " -f2 | /bin/sed -e "/.*\/$/d" | /usr/bin/cpio -pdmvu /var/lib/adt-config1 2>&1 | /bin/grep "^/var" | /bin/sed "s;/var/lib/adt-config1/;;g" | /usr/bin/tr " " "\\n"'
        modifieds_command='cd /var/lib/adt-config ; /usr/bin/rsync -ri --dry-run --checksum --exclude 'additions' --exclude 'deletions' --exclude 'webrootsync'  /var/lib/adt-config/ /var/lib/adt-config1/ | /usr/bin/cut -d" " -f2 | /bin/sed -e  "/.*\/$/d" | /usr/bin/cpio -pdmvu /var/lib/adt-config1 2>&1 | /bin/grep "^/var" | /bin/sed "s;/var/lib/adt-config1/;;g" | /usr/bin/tr " " "\\n"'
        additions=""
        additions=`eval ${additions_command}`
        modifieds=`eval ${modifieds_command}`
        additions="${additions} ${modifieds}"

        if ( [ "${additions}" != "" ] )
        then
                for addition in ${additions}
                do
                        /bin/cp -r /var/lib/adt-config/additions/* /var/lib/config1/
                        place_to_put="`/bin/echo ${addition} | /bin/sed 's:/[^/]*$::'`"
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/lib/adt-config/${addition} additions/${place_to_put} "no"
                done
        fi       
fi

${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "" /var/lib/adt-config.$$
/bin/cp -r /var/lib/adt-config.$$/additions/* /var/lib/adt-config.$$/
for deletion in `/bin/ls /var/lib/adt-config.$$/deletions`
do
        if ( [ -f /var/lib/adt-config.$$/${deletion} ] )
        then
                /bin/rm /var/lib/adt-config.$$/${deletion}
        fi
done


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



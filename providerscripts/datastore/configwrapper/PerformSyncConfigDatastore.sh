#!/bin/sh
#set -x

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh INSTALLED_SUCCESSFULLY`" = "" ] )
then
        exit
fi

if ( [ ! -d /var/lib/adt-config1 ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "" /var/lib/adt-config
        /usr/bin/rsync -ru /var/lib/adt-config/ /var/lib/adt-config1
        /bin/mkdir -p /var/lib/adt-config1
        /bin/cp -r /var/lib/adt-config/* /var/lib/adt-config1/
fi

deletes_command='/usr/bin/rsync -acnv --dry-run --exclude 'additions' --exclude 'deletions' --exclude 'webrootsync' /var/lib/adt-config1/ /var/lib/adt-config 2>&1 | /bin/sed -e "/^$/d" -e  "/.*\/$/d" | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /usr/bin/tr " " "\\n"'
deletes=`eval ${deletes_command}`

if ( [ "${deletes}" != "" ] )
then
        for delete in ${deletes}
        do
                place_to_put=""
                if ( [ "`/bin/echo ${delete} | /bin/grep '/'`" != "" ] )
                then
                        place_to_put="/`/bin/echo ${delete} | /bin/sed 's:/[^/]*$::'`"
                fi
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/lib/adt-config1/${delete} deletions${place_to_put} "no"
        done
fi

additions_command='/usr/bin/rsync -acnv --dry-run --checksum --exclude 'additions' --exclude 'deletions' --exclude 'webrootsync' /var/lib/adt-config/ /var/lib/adt-config1 2>&1 | /bin/sed -e "/^$/d" -e  "/.*\/$/d" | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /usr/bin/tr " " "\\n"'
additions=`eval ${additions_command}`

if ( [ "${additions}" != "" ] )
then
        for addition in ${additions}
        do
                place_to_put=""
                if ( [ "`/bin/echo ${addition} | /bin/grep '/'`" != "" ] )
                then
                        place_to_put="/`/bin/echo ${addition} | /bin/sed 's:/[^/]*$::'`"
                fi
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/lib/adt-config/${addition} additions${place_to_put} "no"
                /usr/bin/rsync -u /var/lib/adt-config/${addition} /var/lib/adt-config1/${addition}
        done
fi    

/bin/sleep 5

${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "" /var/lib/adt-config.$$
/usr/bin/rsync -ru /var/lib/adt-config.$$/additions/ /var/lib/adt-config.$$
/usr/bin/rsync -ru /var/lib/adt-config.$$/additions/ /var/lib/adt-config1
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





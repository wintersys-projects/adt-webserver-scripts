#!/bin/sh
set -x
if ( [ -d /var/lib/adt-config1 ] )
then
        deletes_command='/usr/bin/rsync --dry-run -vr --ignore-existing /var/lib/adt-config1/ /var/lib/adt-config 2>&1 | /bin/sed -e "/^$/d" -e  "/.*\/$/d" | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /usr/bin/tr " " "\\n" '
        deletes=`eval ${deletes_command}`
fi


${HOME}/providerscripts/datastore/configwrapper/SyncToConfigDatastore.sh /var/lib/adt-config/

/bin/sleep 10

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

${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "" /var/lib/adt-config.$$

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



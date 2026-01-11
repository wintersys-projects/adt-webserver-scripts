#!/bin/sh
set -x

machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh INSTALLED_SUCCESSFULLY`" = "" ] )
then
        exit
fi

if ( [ ! -d /var/lib/adt-config1 ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config"
        /usr/bin/rsync -ru /var/lib/adt-config/ /var/lib/adt-config1
fi

if ( [ ! -d /var/lib/adt-config/deletions ] )
then
        /bin/mkdir -p /var/lib/adt-config/deletions
fi

/usr/bin/diff -qr /var/lib/adt-config /var/lib/adt-config1 | /bin/grep "^Only in /var/lib/adt-config1" | /bin/sed -e 's;: ;/;' -e 's:/var/lib/adt-config1/::' | /usr/bin/awk '{print $NF}' > /var/lib/adt-config/de
letions/deletes-${machine_ip}.log

${HOME}/providerscripts/datastore/configwrapper/SyncToConfigDatastore.sh "/var/lib/adt-config" "root"

/bin/sleep 10

if ( [ ! -d /var/lib/adt-config.$$ ] )
then
        /bin/mkdir /var/lib/adt-config.$$
fi

${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config.$$"

if ( [ "`/usr/bin/find /var/lib/adt-config.$$/deletions  -maxdepth 0 -type d -empty 2>/dev/null`" = "" ] )
then
        for file in `/usr/bin/find /var/lib/adt-config.$$/deletions`
        do
                /bin/echo ${file}
        done
fi



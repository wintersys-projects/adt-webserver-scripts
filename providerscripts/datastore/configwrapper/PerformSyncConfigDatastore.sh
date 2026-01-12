#!/bin/sh
#set -x

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh INSTALLED_SUCCESSFULLY`" = "" ] )
then
        exit
fi

if ( [ -d /var/lib/adt-config.old ] )
then
        /bin/rm -r /var/lib/adt-config.old
fi

if ( [ ! -d /var/lib/adt-config1 ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config"
        /usr/bin/rsync -ru /var/lib/adt-config/ /var/lib/adt-config1
fi

if ( [ ! -d ${HOME}/runtime/datastore_workarea/config_deletions ] )
then
        /bin/mkdir -p ${HOME}/runtime/datastore_workarea/config_deletions
fi

/usr/bin/rsync -aq --include='*/' --exclude='*' /var/lib/adt-config/ /var/lib/adt-config1
/usr/bin/diff -qr /var/lib/adt-config /var/lib/adt-config1 | /bin/grep "^Only in /var/lib/adt-config1"  | /bin/sed -e 's;: ;/;'  | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/datastore_workarea/config_deletions/deletes.log

if ( [ -s ${HOME}/runtime/datastore_workarea/config_deletions/deletes.log ] )
then
        for deletion in `/bin/cat ${HOME}/runtime/datastore_workarea/config_deletions/deletes.log`
        do
                if ( [ -f ${deletion} ] )
                then
                        /bin/rm ${deletion}
                fi
                if ( [ -d ${deletion} ] )
                then
                        if ( [ "`/usr/bin/find /var/lib/adt-config.$$/deletions  -maxdepth 0 -type d -empty 2>/dev/null`" != "" ] )
                        then
                                /bin/rm -r ${deletion}
                        fi
                fi
        done
        echo "deletions"
        /bin/cat ${HOME}/runtime/datastore_workarea/config_deletions/deletes.log
fi

if ( [ ! -d ${HOME}/runtime/datastore_workarea/config_additions ] )
then
        /bin/mkdir -p ${HOME}/runtime/datastore_workarea/config_additions
fi

/usr/bin/diff -qr /var/lib/adt-config/ /var/lib/adt-config1 | /bin/grep '^Only in' | /bin/grep '/var/lib/adt-config' | /bin/sed -e 's;: ;/;' | /bin/sed 's://:/:g' | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/datastore_workarea/config_additions/additions.log

if ( [ -s ${HOME}/runtime/datastore_workarea/config_additions/additions.log ] )
then
        for addition in `/bin/cat ${HOME}/runtime/datastore_workarea/config_additions/additions.log`
        do
                /usr/bin/rsync -a ${addition} `/bin/echo ${addition} | /bin/sed 's/adt-config/adt-config1/'`
                echo "additions"
                /bin/cat ${HOME}/runtime/datastore_workarea/config_additions/additions.log
        done
fi

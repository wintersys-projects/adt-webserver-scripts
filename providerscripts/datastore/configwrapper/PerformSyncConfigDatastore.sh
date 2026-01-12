#!/bin/sh
#set -x

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh INSTALLED_SUCCESSFULLY`" = "" ] )
then
        exit
fi

if ( [ ! -d /var/lib/adt-config ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config"
        /usr/bin/rsync -ru /var/lib/adt-config/ /var/lib/adt-config1
fi

if ( [ ! -d ${HOME}/runtime/datastore_workarea/config_deletions ] )
then
        /bin/mkdir -p ${HOME}/runtime/datastore_workarea/config_deletions
fi

/usr/bin/rsync -aq --include='*/' --exclude='*' /var/lib/adt-config/ /var/lib/adt-config1
/usr/bin/rsync -aq --include='*/' --exclude='*' /var/lib/adt-config1/ /var/lib/adt-config


/usr/bin/diff -rq /var/lib/adt-config /var/lib/adt-config1 | /bin/grep "^Only in /var/lib/adt-config1"  | /bin/sed -e 's;: ;/;'  | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/datastore_workarea/config_deletions/deletes.log

if ( [ -s ${HOME}/runtime/datastore_workarea/config_deletions/deletes.log ] )
then
        for deletion in `/bin/cat ${HOME}/runtime/datastore_workarea/config_deletions/deletes.log`
        do
                datastore_deletion="`/bin/echo ${deletion} | /bin/sed 's:/var/lib/adt-config1/::'`"
                if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${datastore_deletion}`" != "" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "${datastore_deletion}" "no" "no"
                fi

                if ( [ -f ${deletion} ] )
                then
                        /bin/rm ${deletion}
                        deletion="`/bin/echo ${deletion} | /bin/sed 's:/[^/]*$::'`"
                fi
                if ( [ -d ${deletion} ] )
                then
                        if ( [ "`/usr/bin/find ${deletion}  -maxdepth 0 -type d -empty 2>/dev/null`" = "" ] )
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

/usr/bin/diff -qr /var/lib/adt-config/ /var/lib/adt-config1 | /bin/grep '^Only in' | /bin/grep '/var/lib/adt-config ' | /bin/sed -e 's;: ;/;' | /bin/sed 's://:/:g' | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/datastore_workarea/config_additions/additions.log
/usr/bin/diff -qr /var/lib/adt-config/ /var/lib/adt-config1 | /bin/grep '^Files.*differ' | /bin/grep '/var/lib/adt-config ' | /usr/bin/awk '{print $2}' >> ${HOME}/runtime/datastore_workarea/config_additions/additions.log

if ( [ -s ${HOME}/runtime/datastore_workarea/config_additions/additions.log ] )
then
        for addition in `/bin/cat ${HOME}/runtime/datastore_workarea/config_additions/additions.log`
        do
                /usr/bin/rsync -a ${addition} `/bin/echo ${addition} | /bin/sed 's/adt-config/adt-config1/'`
                trimmed_addition="`/bin/echo ${addition} | /bin/sed 's:/var/lib/adt-config/::'`"
                if ( [ "`/bin/echo ${trimmed_addition} | /bin/grep '/'`" != "" ] )
                then
                        place_to_put="`/bin/echo ${trimmed_addition} | /bin/sed 's:/[^/]*$::'`"
                else
                        place_to_put="root"
                fi
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh "${addition}"  "${place_to_put}" "no"
        done
        echo "additions"
        /bin/cat ${HOME}/runtime/datastore_workarea/config_additions/additions.log
fi

/bin/sleep 5

if ( [ ! -d ${HOME}/runtime/datastore_workarea/config_additions/brand_new ] )
then
        /bin/mkdir -p ${HOME}/runtime/datastore_workarea/config_additions/brand_new
fi

/bin/rm ${HOME}/runtime/datastore_workarea/config_additions/brand_new/*

/usr/bin/find /var/lib/adt-config -type f -newermt "15 seconds ago" > ${HOME}/runtime/datastore_workarea/config_additions/brand_new.log

if ( [ -s ${HOME}/runtime/datastore_workarea/config_additions/brand_new.log ] )
then
        for new_file in `/bin/cat ${HOME}/runtime/datastore_workarea/config_additions/brand_new.log`
        do
                # place_to_put="`/bin/echo ${new_file} | /bin/sed 's:/var/lib/adt-config/::'`"
                # /usr/bin/rsync -a --mkpath ${new_file} ${HOME}/runtime/datastore_workarea/config_additions/brand_new/${place_to_put}
                file_to_preserve="`/bin/echo ${new_file} | /bin/sed 's:/var/lib/adt-config/::'`"
                /usr/bin/rsync -a --mkpath ${new_file} ${HOME}/runtime/datastore_workarea/config_additions/brand_new/${file_to_preserve}
        done
fi

${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "root" /var/lib/adt-config

if ( [ -s ${HOME}/runtime/datastore_workarea/config_additions/brand_new.log ] )
then
        for restored_file in `/bin/cat ${HOME}/runtime/datastore_workarea/config_additions/brand_new.log`
        do
                file_to_restore="`/bin/echo ${restored_file} | /bin/sed 's:/var/lib/adt-config/::'`"
                /usr/bin/rsync -a --ignore-existing --mkpath ${HOME}/runtime/datastore_workarea/config_additions/brand_new/${file_to_restore} /var/lib/adt-config/${file_to_restore}
                /bin/rm ${HOME}/runtime/datastore_workarea/config_additions/brand_new/${file_to_restore}
        done

fi

if ( [ -f ${HOME}/runtime/datastore_workarea/config_additions/brand_new.log ] )
then
        /bin/rm ${HOME}/runtime/datastore_workarea/config_additions/brand_new.log 
fi


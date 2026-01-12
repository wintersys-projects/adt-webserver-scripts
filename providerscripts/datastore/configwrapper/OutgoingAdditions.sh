#!/bin/sh
set -x

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

if ( [ ! -d ${HOME}/runtime/datastore_workarea/config_additions ] )
then
        /bin/mkdir -p ${HOME}/runtime/datastore_workarea/config_additions
fi

/usr/bin/diff -qr /var/lib/adt-config/ /var/lib/adt-config1 | /bin/grep '^Only in' | /bin/sed -e 's;: ;/;' -e 's;//;/;' |  /bin/grep '/var/lib/adt-config/' | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/datastore_workarea/config_additions/additions.log
/usr/bin/diff -qr /var/lib/adt-config/ /var/lib/adt-config1 | /bin/grep '^Files.*differ' | /usr/bin/awk '{print $2}' >> ${HOME}/runtime/datastore_workarea/config_additions/additions.log

if ( [ -s ${HOME}/runtime/datastore_workarea/config_additions/additions.log ] )
then
        for addition in `/bin/cat ${HOME}/runtime/datastore_workarea/config_additions/additions.log`
        do
                addition_copy_file="`/bin/echo ${addition} | /bin/sed 's/adt-config/adt-config1/'`"
                addition_directory="`/bin/echo ${addition_copy_file} | /bin/sed 's:/[^/]*$::'`"
                if ( [ ! -d ${addition_directory} ] )
                then
                        /bin/mkdir -p ${addition_directory}
                fi
                /bin/cp ${addition} ${addition_copy_file}
                if ( [ "`/bin/echo ${addition} | /bin/sed 's:[^/]::g' | /usr/bin/awk '{print length}'`" = "4" ] )
                then
                        place_to_put="root"
                else
                        place_to_put="`/bin/echo ${addition} | /bin/sed 's:/var/lib/adt-config/::'`"
                fi
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh "${addition}"  "${place_to_put}" "no"
        done
fi

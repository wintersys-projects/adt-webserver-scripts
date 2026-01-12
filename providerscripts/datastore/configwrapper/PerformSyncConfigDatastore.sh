#!/bin/sh
#set -x

machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

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

if ( [ ! -d /var/lib/adt-config/deletions ] )
then
        /bin/mkdir -p /var/lib/adt-config/deletions
fi

/usr/bin/diff -qr /var/lib/adt-config /var/lib/adt-config1 | /bin/grep "^Only in /var/lib/adt-config1" | /bin/grep -v 'deletions' | /bin/sed -e 's;: ;/;' -e 's:/var/lib/adt-config1/::' | /usr/bin/awk '{print $NF}' > /var/lib/adt-config/deletions/deletes-${machine_ip}.log

${HOME}/providerscripts/datastore/configwrapper/SyncToConfigDatastore.sh "/var/lib/adt-config" "root"

if ( [ -f /var/lib/adt-config/deletions/deletes-${machine_ip}.log ] )
then
        for delete in `/bin/cat /var/lib/adt-config/deletions/deletes-${machine_ip}.log`
        do
                if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${delete}`" != "" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "${delete}" "no" "no"
                fi
        done
fi

/bin/sleep 5

if ( [ ! -d /var/lib/adt-config.$$ ] )
then
        /bin/mkdir /var/lib/adt-config.$$
fi

${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config.$$"

if ( [ "`/usr/bin/find /var/lib/adt-config.$$/deletions  -maxdepth 0 -type d -empty 2>/dev/null`" = "" ] )
then
        for file in `/usr/bin/find /var/lib/adt-config.$$/deletions | /bin/grep '.log$'`
        do
                deletes="`/bin/cat ${file}`"
                for delete in ${deletes}
                do
                        if ( [ -f /var/lib/adt-config/${delete} ] )
                        then
                                /bin/rm /var/lib/adt-config/${delete}
                        fi
                        if ( [ -f /var/lib/adt-config.$$/${delete} ] )
                        then
                                /bin/rm /var/lib/adt-config.$$/${delete}
                        fi
                        if ( [ -f /var/lib/adt-config1/${delete} ] )
                        then
                                /bin/rm /var/lib/adt-config1/${delete}
                        fi

                        if ( [ -d /var/lib/adt-config/${delete} ] )
                        then
                                /bin/rm -r /var/lib/adt-config/${delete}
                        fi
                        if ( [ -d /var/lib/adt-config.$$/${delete} ] )
                        then
                                /bin/rm -r /var/lib/adt-config.$$/${delete}
                        fi
                        if ( [ -d /var/lib/adt-config1/${delete} ] )
                        then
                                /bin/rm -r /var/lib/adt-config1/${delete}
                        fi
                        if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${delete}`" != "" ] )
                        then
                                ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "${delete}" "no" "no"
                        fi
                done

                if ( [ -d ${file} ] )
                then
                        /bin/rm -r ${file}
                else
                        /bin/rm ${file}
                fi
        done
fi

additions=`/usr/bin/diff -qr /var/lib/adt-config.$$ /var/lib/adt-config | /bin/grep '^Only in' | /bin/grep -v 'deletions' | /bin/grep '/var/lib/adt-config' | /bin/sed -e 's;: ;/;' -e 's:/var/lib/adt-config/::' | /usr/bin/awk '{print $NF}'`
/usr/bin/rsync -avr --include='*/' --exclude='*' /var/lib/adt-config/ /var/lib/adt-config.$$

if ( [ "${additions}" != "" ] )
then
        for addition in ${additions}
        do
                if ( [ "`/bin/echo "${addition}" | /bin/grep '/'`" != "" ] )
                then
                        place_to_put="`/bin/echo ${addition}  | /bin/sed 's:/[^/]*$::'`/"
                else
                        place_to_put=""
                fi
                /usr/bin/rsync -a /var/lib/adt-config/${addition} /var/lib/adt-config.$$/${place_to_put}
        done
fi

if ( [ -d /var/lib/adt-config ] )
then
        /bin/mv /var/lib/adt-config /var/lib/adt-config.old
fi

/bin/mv /var/lib/adt-config.$$ /var/lib/adt-config

additions=`/usr/bin/diff -qr /var/lib/adt-config /var/lib/adt-config1 | /bin/grep '^Only in' | /bin/grep -v 'deletions' | /bin/grep '/var/lib/adt-config' | /bin/sed -e 's;: ;/;' -e 's:/var/lib/adt-config/::' | /usr/bin/awk '{print $NF}'`
/usr/bin/rsync -avr --include='*/' --exclude='*' /var/lib/adt-config/ /var/lib/adt-config1

if ( [ "${additions}" != "" ] )
then
        for addition in ${additions}
        do
                if ( [ "`/bin/echo "${addition}" | /bin/grep '/'`" != "" ] )
                then
                        place_to_put="`/bin/echo ${addition}  | /bin/sed 's:/[^/]*$::'`/"
                else
                        place_to_put=""
                fi
                /usr/bin/rsync -a /var/lib/adt-config/${addition} /var/lib/adt-config1/${place_to_put}
        done
fi

if ( [ -d /var/lib/adt-config.old ] )
then
        /bin/rm -r /var/lib/adt-config.old
fi


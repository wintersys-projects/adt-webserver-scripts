#set -x

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ""`" = "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "" /var/lib/adt-config
fi

if ( [ ! -d /var/lib/adt-config-1 ] )
then
        /bin/mkdir /var/lib/adt-config-1
        /bin/cp -r /var/lib/adt-config/* /var/lib/adt-config-1
        exit
fi

deletions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh deletions`"
if ( [ "${deletions}" = "" ] )
then
        for file in ${deletions}
        do
                if ( [ -f /var/lib/adt-config/${file} ] )
                then
                        /bin/rm /var/lib/adt-config/${file} 
                fi
                if ( [ -f /var/lib/adt-config1/${file} ] )
                then
                        /bin/rm /var/lib/adt-config1/${file} 
                fi
        done
fi

deletes_command='/usr/bin/rsync --dry-run --ignore-existing -vr /var/lib/adt-config-1/ /var/lib/adt-config/ 2>&1 | /bin/sed -e "/^$/d" -e  "/.*\/$/d" | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /usr/bin/tr " "
"\\n" '

deletes=`eval ${deletes_command}`

for file in ${deletes}
do
        file="`/bin/echo ${file} | /bin/sed 's:/var/lib/adt-config/::'`"
        if ( [ -f /var/lib/adt-config/${file} ] && [ "`/usr/bin/find /var/lib/adt-config/${file} -mmin +1`" != "" ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh ${file} 
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${file} deletions "yes"
                /bin/rm /var/lib/adt-config-1/${file}
        else
                if ( [ -f /var/lib/adt-config/${file} ] )
                then
                        /bin/cp /var/lib/adt-config/${file} /var/lib/adt-config-1/${file}
                fi
        fi
done

additions="`/usr/bin/find /var/lib/adt-config/ -type f -mmin -1 | /bin/sed 's:/var/lib/adt-config/::'`"

if ( [ "${additions}" != "" ] )
then
        for file in ${additions}
        do
                place_to_put=""
                if ( [ "`/bin/echo ${file} | /bin/grep '/'`" != "" ] )
                then
                        place_to_put="`/bin/echo ${file} | /bin/sed 's:/[^/]*$::'`"
                fi

                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/lib/adt-config/${file} ${place_to_put} "no"

                if ( [ ! -d /var/lib/adt-config/additions/${place_to_put} ] )
                then
                        /bin/mkdir -p /var/lib/adt-config/additions/${place_to_put}
                fi
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/lib/adt-config/${file} additions "no"


                if ( [ "${place_to_put}" != "" ] && [ ! -d /var/lib/adt-config-1/${place_to_put} ] )
                then
                        /bin/mkdir -p /var/lib/adt-config-1/${place_to_put}
                fi

                /bin/cp /var/lib/adt-config/${file} /var/lib/adt-config-1/${file} 
        done
fi

incoming_additions="`/usr/bin/find /var/lib/adt-config/additions -type f -mmin -1`"
#/usr/bin/rsync -a --maxdepth 1 --exclude /var/lib/adt-config/additions/ /var/lib/adt-config/

incoming_deletions="`/bin/ls /var/lib/adt-config/deletions`"

for incoming_deletion in ${incoming_deletions}
do
        if ( [ -f /var/lib/adt-config/${incoming_deletion} ] )
        then
                /bin/rm /var/lib/adt-config/${incoming_deletion}
        fi
        if ( [ -f /var/lib/adt-config-1/${incoming_deletion} ] )
        then
                /bin/rm /var/lib/adt-config-1/${incoming_deletion}
        fi
done



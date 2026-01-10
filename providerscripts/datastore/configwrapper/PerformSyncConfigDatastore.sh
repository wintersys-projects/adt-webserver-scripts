#set -x

if ( [ ! -d /var/lib/adt-config ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "" /var/lib/adt-config
fi

if ( [ ! -d /var/lib/adt-config-1 ] )
then
        /bin/mkdir /var/lib/adt-config-1
        /bin/cp -r /var/lib/adt-config/* /var/lib/adt-config-1
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

${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "/additions" /var/lib/adt-config

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

additions="`/usr/bin/find /var/lib/adt-config/ -mmin -1`"

if ( [ "${additions}" != "" ] )
then
        file="`/bin/echo ${file} | /bin/sed 's:/var/lib/adt-config/::' | sed 's:/[^/]*$::'`"
        if ( [ -f ${file} ] )
        then
                for file in ${additions}
                do
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${file} ${place_to_put} "no"
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${file} additions "no"

                        /bin/cp ${file} `/bin/echo ${file} | /bin/sed 's:adt-config:adt-config-1:'`
                done
        fi
fi



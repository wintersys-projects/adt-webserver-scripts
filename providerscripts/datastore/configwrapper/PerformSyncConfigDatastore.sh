#set -x

if ( [ ! -d /var/lib/adt-config-1 ] )
then
        /bin/mkdir /var/lib/adt-config-1
        /bin/cp -r /var/lib/adt-config/* /var/lib/adt-config-1
fi

deletes_command='/usr/bin/rsync --dry-run --ignore-existing -vr /var/lib/adt-config-1/ /var/lib/adt-config/ 2>&1 | /bin/sed -e "/^$/d" -e  "/.*\/$/d" | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /usr/bin/tr " "
"\\n" '

deletes=`eval ${deletes_command}`

for file in ${deletes}
do
        if ( [ /usr/bin/find /var/lib/adt-config/${file} -mmin +1 ] )
        then
                ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh/${file}
                /bin/rm /var/lib/adt-config-1/${file}
        else
                /bin/cp /var/lib/adt-config/${file} /var/lib/adt-config-1/${file}
        fi
done

additions="`/usr/bin/find /var/lib/adt-config/ -mmin -1`"

for file in ${additions}
do
        /bin/cp ${file} `/bin/echo ${file} | /bin/sed 's:adt-config:adt-config-1:'`
done

${HOME}/providerscripts/datastore/configwrapper/SyncToConfigDatastore.sh /var/lib/adt-config ""
${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "" /var/lib/adt-config



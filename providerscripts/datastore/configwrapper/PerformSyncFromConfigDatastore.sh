set -x

${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "" /var/lib/adt-config

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
        /bin/rm /var/lib/adt-config-1/${file}
done

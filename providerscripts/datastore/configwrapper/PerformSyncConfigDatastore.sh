#!/bin/sh
#set -x

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh INSTALLED_SUCCESSFULLY`" = "" ] )
then
        exit
fi

if ( [ ! -d /var/lib/adt-config ] )
then
        /bin/mkdir /var/lib/adt-config
        ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config"
fi

if ( [ ! -d /var/lib/adt-config1 ] )
then
        /bin/mkdir /var/lib/adt-config1
fi

if ( [ ! -d ${HOME}/runtime/datastore_workarea/config_updates ] )
then
        /bin/mkdir -p ${HOME}/runtime/datastore_workarea/config_updates
fi

if ( [ ! -d ${HOME}/runtime/datastore_workarea/config_newcreates ] )
then
        /bin/mkdir -p ${HOME}/runtime/datastore_workarea/config_newcreates
fi

monitor_for_datastore_changes() {

        if ( [ ! -d /var/lib/adt-config1 ] )
        then
                /bin/mkdir /var/lib/adt-config1
        fi

        while ( [ 1 ] )
        do
                /bin/sleep 5
                ${HOME}/providerscripts/datastore/configwrapper/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config" "yes" > ${HOME}/runtime/datastore_workarea/config_updates/updates.log
                if ( [ -f ${HOME}/runtime/datastore_workarea/config_updates/updates.log ] )
                then
                        set -x
                        while IFS= read -r line 
                        do
                                if ( [ "`/bin/echo ${line} | /bin/grep "^delete:"`" != "" ] )
                                then
                                        file_to_delete="`/bin/echo ${line} | /usr/bin/awk -F"'" '{print $2}'`"
                                        if ( [ ! -d ${file_to_delete} ] )
                                        then
                                                if ( [ "`/bin/grep ${file_to_delete} ${HOME}/runtime/datastore_workarea/config_newcreates/newcreates.log`" = "" ] )
                                                then
                                                        /bin/rm ${file_to_delete}
                                                else 
                                                        /bin/sed -i "\:${file_to_delete}:d" ${HOME}/runtime/datastore_workarea/config_newcreates/newcreates.log
                                                        /bin/sed -i "\:${file_to_delete}:d" ${HOME}/runtime/datastore_workarea/config_updates/updates.log
                                                        if ( [ "`/bin/echo ${place_to_put} | /bin/grep '/'`" != "" ] )
                                                        then
                                                                place_to_put="`/bin/echo ${file_to_delete} | /bin/sed 's:/var/lib/adt-config/::' | /bin/sed 's:/[^/]*$::'`/"
                                                        else
                                                                place_to_put="root"
                                                        fi
                                                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${file_to_delete} ${place_to_put}
                                                fi
                                        fi
                                elif ( [ "`/bin/echo ${line} | /bin/grep "^download:"`" != "" ] )
                                then
                                        file_to_obtain="`/bin/echo ${line} | /usr/bin/awk -F"'" '{print $2}' | /usr/bin/cut -f4- -d'/'`"
                                        place_to_put="`/bin/echo ${line} | /usr/bin/awk -F"'" '{print $4}'| /bin/sed 's/adt-config/adt-config1/'`"
                                        if ( [ "`/bin/echo ${place_to_put} | /bin/grep '/'`" != "" ] )
                                        then
                                                place_to_put="`/bin/echo ${place_to_put} | /bin/sed 's:/[^/]*$::'`"
                                        else
                                                place_to_put="root"
                                        fi

                                        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ${file_to_obtain} ${place_to_put}
                                        file_to_sync="${place_to_put}"
                                        file_to_sync_to="`/bin/echo ${place_to_put} | /bin/sed 's/adt-config1/adt-config/'`"
                                        /usr/bin/rsync -a --mkpath --checksum ${file_to_sync} ${file_to_sync_to}
                                fi

                        done < "${HOME}/runtime/datastore_workarea/config_updates/updates.log"

                fi
        done
}


monitor_for_datastore_changes &

file_removed() {
        echo "DELETED"
        live_dir="${1}"
        deleted_file="${2}"

        check_dir="`/bin/echo ${live_dir} | /bin/sed 's/adt-config/adt-config1/g'`"

        if ( [ -f ${check_dir}/${deleted_file} ] )
        then
                /bin/rm ${check_dir}/${deleted_file}
        fi

        if ( [ -f ${live_dir}/${deleted_file} ] )
        then
                /bin/rm ${live_dir}/${deleted_file}
        fi

        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "${deleted_file}" "no" "no"

}

file_modified() {
        echo "MODIFIED"
        live_dir="${1}"
        modified_file="${2}"
        check_dir="`/bin/echo ${live_dir} | /bin/sed 's/adt-config/adt-config1/g'`"

        if ( [ "`/bin/echo ${modified_file} | /bin/grep '^\.'`" = "" ] )
        then
                if ( [ ! -f ${check_dir}/${modified_file} ] ||  [ "`/usr/bin/diff ${live_dir}/${modified_file} ${check_dir}/${modified_file}`" != "" ] )
                then
                        if ( [ "`/bin/echo ${modified_file} | /bin/grep '/'`" != "" ] )
                        then
                                place_to_put="`/bin/echo ${modified_file} | /bin/sed 's:/[^/]*$::'`/"
                        else
                                place_to_put="root"
                        fi
                
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${live_dir}${modified_file} ${place_to_put}
                else
                        if ( [ -f ${check_dir}/${modified_file} ] )
                        then
                                /bin/rm ${check_dir}/${modified_file}
                        fi
                fi
        fi
        
}

file_created() {
        echo "CREATED"
        live_dir="${1}"
        created_file="${2}"

        if ( [ "`/bin/echo ${created_file} | /bin/grep '^\.'`" = "" ] )
        then
                if ( [ ! -d ${live_dir}${created_file} ] )
                then
                        /bin/echo "${live_dir}${created_file}" >> ${HOME}/runtime/datastore_workarea/config_newcreates/newcreates.log
                        check_dir="`/bin/echo ${live_dir} | /bin/sed 's/adt-config/adt-config1/g'`"

                        if ( [ ! -f ${check_dir}/${created_file} ] ||  [ "`/usr/bin/diff ${live_dir}/${created_file} ${check_dir}/${created_file}`" != "" ] )
                        then
                                if ( [ "`/bin/echo ${created_file} | /bin/grep '/'`" != "" ] )
                                then
                                        place_to_put="`/bin/echo ${created_file} | /bin/sed 's:/[^/]*$::'`/"
                                else
                                        place_to_put="root"
                                fi
                
                                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh  ${live_dir}${modified_file} ${place_to_put}
                                /bin/echo "needed" >> monitor_log
                        else
                                if ( [ -f ${check_dir}/${created_file} ] )
                                then
                                        /bin/rm ${check_dir}/${created_file}
                                fi
                        fi
                fi
        fi
}

/usr/bin/inotifywait -q -m -r -e modify,delete,create /var/lib/adt-config | while read DIRECTORY EVENT FILE 
do
        case $EVENT in
                MODIFY*)
                        file_modified "$DIRECTORY" "$FILE"
                        ;;
                CREATE*)
                        file_created "$DIRECTORY" "$FILE"
                        ;;
                DELETE*)
                        file_removed "$DIRECTORY" "$FILE"
                        ;;
        esac
done

exit

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
                fi
        done
        echo "deletions"
        /bin/cat ${HOME}/runtime/datastore_workarea/config_deletions/deletes.log
fi

/usr/bin/find /var/lib/adt-config -type d -empty -delete
/usr/bin/find /var/lib/adt-config1 -type d -empty -delete

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

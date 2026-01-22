#!/bin/sh
set -x

exec 1>/tmp/out
exec 2>/tmp/err

if ( [ ! -d /var/lib/adt-config ] )
then
        /bin/mkdir /var/lib/adt-config
        ${HOME}/providerscripts/datastore/config/toolkit/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config"
fi


monitor_for_datastore_changes() {
        while ( [ 1 ] )
        do
                /bin/sleep 30
                ${HOME}/providerscripts/datastore/config/toolkit/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config"

                for file_to_delete_marker in `/usr/bin/find /var/lib/adt-config | /bin/grep 'delete_me$'`
                do
                        if ( [ -f ${file_to_delete_marker} ] )
                        then
                                /bin/rm ${file_to_delete_marker}
                        fi

                        if ( [ -f `/bin/echo ${file_to_delete_marker} | /bin/sed 's:\.delete_me::g'` ] )
                        then
                                /bin/rm `/bin/echo ${file_to_delete_marker} | /bin/sed 's:\.delete_me::g'`
                        fi

                        file_to_delete_marker="`/bin/echo ${file_to_delete_marker} | /bin/sed -e 's:/var/lib/adt-config/::g'`"
                        file_to_delete_real="`/bin/echo ${file_to_delete_marker} | /bin/sed -e 's:/var/lib/adt-config/::g' -e 's/\.delete_me//g'`"
                        ${HOME}/providerscripts/datastore/config/toolkit/DeleteFromConfigDatastore.sh "${file_to_delete_marker}" 
                        ${HOME}/providerscripts/datastore/config/toolkit/DeleteFromConfigDatastore.sh "${file_to_delete_real}" 
                done

                if ( [ -d /var/lib/adt-config ] )
                then
                        /usr/bin/find /var/lib/adt-config -type d -empty -delete
                fi
        done
}

monitor_for_datastore_changes &

/usr/bin/inotifywait -q -m -r -e modify,delete,create /var/lib/adt-config | while read DIRECTORY EVENT FILE 
do
        if ( [ -f ${DIRECTORY}${FILE} ] && ( [ "`/bin/echo ${FILE} | /bin/grep "^\."`" = "" ] && [ "`/bin/echo ${FILE} | /bin/grep '\~$'`" = "" ] && [ "`/bin/echo ${FILE} | /bin/grep  -E '\.[a-z0-9]{8,}\.partial$'`" = "" ] && [ "`/bin/echo ${FILE} | /bin/grep  '\.delete_me$'`" = "" ]  ) || [ "${EVENT}" = "DELETE" ]  )
        then
                case ${EVENT} in
                        MODIFY*)
                                file_for_processing="${DIRECTORY}${FILE}"
                                if ( [ "`/bin/echo ${file_for_processing} | /bin/sed 's:/: :g' | /usr/bin/wc -w`" -gt "4" ] )
                                then
                                        place_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::' | /bin/sed 's:/var/lib/adt-config/::g'`"
                                else
                                        place_to_put="root"
                                fi
                                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh ${file_for_processing} ${place_to_put} "no" 
                                ;;
                        CREATE*)
                                file_for_processing="${DIRECTORY}${FILE}"
                                if ( [ "`/bin/echo ${file_for_processing} | /bin/sed 's:/: :g' | /usr/bin/wc -w`" -gt "4" ] )
                                then
                                        place_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::' | /bin/sed 's:/var/lib/adt-config/::g'`"
                                else
                                        place_to_put="root"
                                fi
                                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh ${file_for_processing} ${place_to_put} "no" 
                                ;;
                        DELETE*)
                                file_for_processing="${DIRECTORY}${FILE}"
                                if ( [ "`/bin/echo ${file_for_processing} | /bin/sed 's:/: :g' | /usr/bin/wc -w`" -gt "4" ] )
                                then
                                        place_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::' | /bin/sed 's:/var/lib/adt-config/::g'`"
                                else
                                        place_to_put="root"
                                fi
                                if ( [ ! -f ${file_for_processing}.delete_me ] )
                                then
                                        /bin/touch ${file_for_processing}.delete_me
                                        ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh ${file_for_processing}.delete_me ${place_to_put} "yes" 
                                fi
                                ;;
                esac
        fi
done

#!/bin/sh
set -x

exec 1>/tmp/out
exec 2>/tmp/err

if ( [ ! -d /var/lib/adt-config ] )
then
        /bin/mkdir /var/lib/adt-config
        ${HOME}/providerscripts/datastore/config/toolkit/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config"
fi

/bin/echo "32768" > /proc/sys/fs/inotify/max_queued_events
/bin/echo "512" > /proc/sys/fs/inotify/max_user_instances                                                    

monitor_for_datastore_changes() {
        while ( [ 1 ] )
        do
                /bin/sleep 15
                if ( [ -f ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log ] )
                then
                        /usr/bin/uniq ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log  > ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log.$$
                        /bin/mv ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log.$$ ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log
                        total_no_records="`/usr/bin/wc -l ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log | /usr/bin/awk '{print $1}'`"
                        processed_no_records="`/bin/cat ${HOME}/runtime/datastore_workarea/config/incoming_records_index.dat`"
                        to_process_no_records="`/usr/bin/expr ${total_no_records} - ${processed_no_records}`"
                       
                        if ( [ "${total_no_records}" != "${processed_no_records}" ] )
                        then
                                /usr/bin/head -${total_no_records} ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log  | /usr/bin/tail -${to_process_no_records} > ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log.$$
                                /bin/echo "${total_no_records}" > ${HOME}/runtime/datastore_workarea/config/incoming_records_index.dat
                        fi

                        /bin/cat ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log.$$ | /usr/bin/uniq | while read file_to_add place_to_put
                        do
                                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh ${file_to_add} ${place_to_put} "no" 
                        done
                        if ( [ -f ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log.$$ ] )
                        then
                                /bin/rm ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log.$$
                        fi
                fi

                ${HOME}/providerscripts/datastore/config/toolkit/SyncFromConfigDatastore.sh "root" "/var/lib/adt-config"

                for deleted_file in `/usr/bin/find /var/lib/adt-config | /bin/grep '\.delete_me$'`
                do
                        marker_file="${deleted_file}"
                        real_file="`/bin/echo ${marker_file} | /bin/sed 's:\.delete_me::g'`"
                        if ( [ -f ${marker_file} ] )
                        then
                                /bin/rm ${marker_file}
                        fi
                        if ( [ -f ${real_file} ] )
                        then
                                /bin/touch ${real_file}.cleaningup
                                /bin/rm ${real_file}
                        fi
                        datastore_marker_file="`/bin/echo ${marker_file} | /bin/sed -e 's:/var/lib/adt-config/::g'`"
                        datastore_real_file="`/bin/echo ${real_file} | /bin/sed -e 's:/var/lib/adt-config/::g' -e 's/\.delete_me//g'`"
                        ${HOME}/providerscripts/datastore/config/toolkit/DeleteFromConfigDatastore.sh "${datastore_marker_file}"
                        ${HOME}/providerscripts/datastore/config/toolkit/DeleteFromConfigDatastore.sh "${datastore_real_file}"

                done
                
                if ( [ -d /var/lib/adt-config ] )
                then
                        /usr/bin/find /var/lib/adt-config -type d -empty -delete
                fi
        done
}

monitor_for_datastore_changes &

if ( [ ! -d ${HOME}/runtime/datastore_workarea/config ] )
then
        /bin/mkdir -p ${HOME}/runtime/datastore_workarea/config
fi

if ( [ ! -f ${HOME}/runtime/datastore_workarea/config/incoming_records_index.dat ] )
then
        /bin/echo "0" > ${HOME}/runtime/datastore_workarea/config/incoming_records_index.dat
fi

/usr/bin/inotifywait -q -m -r -e delete,modify,create,move_to,move_from /var/lib/adt-config | while read DIRECTORY EVENT FILE 
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
                                /bin/echo "${file_for_processing} ${place_to_put}" >> ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log
                                ;;
                        CREATE*)
                                file_for_processing="${DIRECTORY}${FILE}"
                                if ( [ "`/bin/echo ${file_for_processing} | /bin/sed 's:/: :g' | /usr/bin/wc -w`" -gt "4" ] )
                                then
                                        place_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::' | /bin/sed 's:/var/lib/adt-config/::g'`"
                                else
                                        place_to_put="root"
                                fi
                                /bin/echo "${file_for_processing} ${place_to_put}" >> ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log
                                ;;
                        MOVE_TO*)
                                file_for_processing="${DIRECTORY}${FILE}"
                                if ( [ "`/bin/echo ${file_for_processing} | /bin/sed 's:/: :g' | /usr/bin/wc -w`" -gt "4" ] )
                                then
                                        place_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::' | /bin/sed 's:/var/lib/adt-config/::g'`"
                                else
                                        place_to_put="root"
                                fi
                                /bin/echo "${file_for_processing} ${place_to_put}" >> ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log
                                ;;
                        MOVE_FROM*)
                                file_for_processing="${DIRECTORY}${FILE}"
                                if ( [ "`/bin/echo ${file_for_processing} | /bin/sed 's:/: :g' | /usr/bin/wc -w`" -gt "4" ] )
                                then
                                        place_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::' | /bin/sed 's:/var/lib/adt-config/::g'`"
                                else
                                        place_to_put="root"
                                fi
                                /bin/echo "${file_for_processing} ${place_to_put}" >> ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log
                                ;;
                        DELETE*)
                                file_for_processing="${DIRECTORY}${FILE}"
                                if ( [ ! -d ${file_for_processing} ] && [ ! -f ${file_for_processing}.cleaningup ] )
                                then
                                        if ( [ "`/bin/echo ${file_for_processing} | /bin/sed 's:/: :g' | /usr/bin/wc -w`" -gt "4" ] )
                                        then
                                                place_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::' | /bin/sed 's:/var/lib/adt-config/::g'`"
                                        else
                                                place_to_put="root"
                                        fi
                                        if ( [ ! -f ${file_for_processing}.delete_me ] && [ "`/bin/echo ${file_for_processing} | /bin/grep '\.delete_me$'`" = "" ] )
                                        then
                                                /bin/touch ${file_for_processing}.delete_me
                                                /bin/echo "${file_for_processing}.delete_me ${place_to_put}" >> ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log
                                        fi
                                fi
                                if ( [ -f ${file_for_processing}.cleaningup ] )
                                then
                                        /bin/rm ${file_for_processing}.cleaningup
                                fi
                                ;;
                esac
        fi
done

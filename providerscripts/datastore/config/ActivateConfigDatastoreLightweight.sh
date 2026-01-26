#!/bin/sh
#set -x

exec 1>/tmp/out
exec 2>/tmp/err

active_directory="${1}"

if ( [ ! -d ${active_directory} ] )
then
        /bin/mkdir ${active_directory}
        ${HOME}/providerscripts/datastore/operations/SyncFromDatastore.sh "config" "root" "${active_directory}"
fi

if ( [ ! -d ${HOME}/runtime/datastore_workarea/config ] )
then
        /bin/mkdir -p ${HOME}/runtime/datastore_workarea/config
else
        /bin/rm -r ${HOME}/runtime/datastore_workarea/config/*
fi

if ( [ ! -f ${HOME}/runtime/datastore_workarea/config/incoming_records_index.dat ] )
then
        /bin/echo "0" > ${HOME}/runtime/datastore_workarea/config/incoming_records_index.dat
fi

update_to_and_from_datastore()
{
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

                                /bin/cat ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log.$$ | while read file_to_add place_to_put
                        do
                                ${HOME}/providerscripts/datastore/operations/PutToDatastore.sh "config" "${file_to_add}" "${place_to_put}" "local" "no"
                        done
                        fi
                        if ( [ -f ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log.$$ ] )
                        then
                                /bin/rm ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log.$$
                        fi
                fi

                ${HOME}/providerscripts/datastore/operations/SyncFromDatastore.sh "config" "root" "${active_directory}"

                for deleted_file in `/usr/bin/find ${active_directory} | /bin/grep '\.delete_me$'`
                do
                        marker_file="${deleted_file}"
                        modified_file="`/bin/echo ${marker_file} | /bin/sed 's:\.delete_me:\.modified_me:g'`"
                        real_file="`/bin/echo ${marker_file} | /bin/sed 's:\.delete_me::g'`"
                        
                        if ( [ -f ${marker_file} ] )
                        then
                                /bin/rm ${marker_file}
                        fi
                        
                        if ( [ -f ${real_file} ] )
                        then
                                /bin/touch ${real_file}.cleaningup
                        fi

                        if ( [ ! -f ${modified_file} ] )
                        then
                                datastore_marker_file="`/bin/echo ${marker_file} | /bin/sed -e "s:${active_directory}/::g"`"
                                datastore_real_file="`/bin/echo ${real_file} | /bin/sed -e "s:${active_directory}/::g" -e 's/\.delete_me//g'`"
                                ${HOME}/providerscripts/datastore/operations/DeleteFromDatastore.sh "config" "${datastore_marker_file}" "local" 
                                ${HOME}/providerscripts/datastore/operations/DeleteFromDatastore.sh "config" "${datastore_real_file}" "local" 
                        fi
                        
                        if ( [ -f ${real_file} ] )
                        then
                                /bin/rm ${real_file}
                        fi
                        
                        if ( [ -f ${real_file}.cleaningup ] )
                        then
                                /bin/rm ${real_file}.cleaningup 
                        fi

                        if ( [ -f ${modified_file} ] )
                        then
                                /bin/rm ${modified_file} 
                        fi
                done

                if ( [ -d ${active_directory} ] )
                then
                        /usr/bin/find ${active_directory} -type d -empty -delete
                fi
        done
}

update_to_and_from_datastore &

/usr/bin/inotifywait -q -m -r -e delete,modify,create ${active_directory} | while read DIRECTORY EVENT FILE 
do          
        /bin/echo "${DIRECTORY}XXX${FILE}" >> /tmp/file_out
        
        if ( [ -f ${DIRECTORY}${FILE} ] && ( [ "`/bin/echo ${FILE} | /bin/grep "^\."`" = "" ] && [ "`/bin/echo ${FILE} | /bin/grep '\~$'`" = "" ] && [ "`/bin/echo ${FILE} | /bin/grep  -E '\.[a-z0-9]{8,}\.partial$'`" = "" ] && [ "`/bin/echo ${FILE} | /bin/grep  '\.delete_me$'`" = "" ] && [ "`/bin/echo ${FILE} | /bin/grep  '\.modified_me$'`" = "" ] && [ "`/bin/echo ${FILE} | /bin/grep  'cleaningup'`" = "" ] ) || [ "${EVENT}" = "DELETE" ]  )
        then
                case ${EVENT} in
                        MODIFY*)
                                file_for_processing="${DIRECTORY}${FILE}"
                                if ( [ "`/bin/echo ${file_for_processing} | /bin/fgrep -o '/' | /usr/bin/wc -l`" -gt "4" ] )
                                then
                                        place_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::' | /bin/sed "s:${active_directory}/::g"`"
                                else
                                        place_to_put="root"
                                fi

                                if ( [ ! -d /var/lib/adt-config/${place_to_put} ] )
                                then
                                        /bin/mkdir -p /var/lib/adt-config/${place_to_put}
                                fi

                                /bin/touch ${file_for_processing}.modified_me
                                /bin/echo "${file_for_processing} ${place_to_put}" >> ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log
                                ;;
                        CREATE*)
                                file_for_processing="${DIRECTORY}${FILE}"
                                if ( [ "`/bin/echo ${file_for_processing} | /bin/fgrep -o '/' | /usr/bin/wc -l`" -gt "4" ] )
                                then
                                        place_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::' | /bin/sed "s:${active_directory}/::g"`"
                                else
                                        place_to_put="root"
                                fi
                                /bin/echo "${file_for_processing} ${place_to_put}" >> ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log
                                ;;
                        DELETE*)
                                file_for_processing="${DIRECTORY}${FILE}"
                                if ( [ ! -d ${file_for_processing} ]  && [ ! -f ${file_for_processing}.cleaningup ] )
                                then
                                        if ( [ "`/bin/echo ${file_for_processing} | /bin/fgrep -o '/' | /usr/bin/wc -l`" -gt "4" ] )
                                        then
                                                place_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::' | /bin/sed "s:${active_directory}/::g"`"
                                        else
                                                place_to_put="root"
                                        fi

                                        if ( [ ! -f ${file_for_processing}.delete_me ] && [ "`/bin/echo ${file_for_processing} | /bin/grep '\.delete_me'`" = "" ] )
                                        then
                                                if ( [ ! -d /var/lib/adt-config/${place_to_put} ] )
                                                then
                                                        /bin/mkdir -p /var/lib/adt-config/${place_to_put}
                                                fi
                                                /bin/touch ${file_for_processing}.delete_me
                                                /bin/echo "${file_for_processing}.delete_me ${place_to_put}" >> ${HOME}/runtime/datastore_workarea/config/additions_to_perform.log
                                        fi
                                fi
                             #   if ( [ -f ${file_for_processing}.cleaningup ] )
                             #   then
                             #           /bin/rm ${file_for_processing}
                             #   fi
                                ;;
                esac
        fi
done

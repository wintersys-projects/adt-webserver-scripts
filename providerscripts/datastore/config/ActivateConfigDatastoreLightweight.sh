#!/bin/sh
set -x

exec 1>/tmp/out
exec 2>/tmp/err

if ( [ ! -d /var/lib/adt-config ] )
then
        /bin/mkdir /var/lib/adt-config
		${HOME}/providerscripts/datastore/config/toolkit/SyncFromConfigDatastoreWithDelete.sh "root" "/var/lib/adt-config"
fi

if ( [ ! -d /var/lib/adt-config-processing ] )
then
	/bin/mkdir /var/lib/adt-config-processing
fi

monitor_for_datastore_changes() {
        while ( [ 1 ] )
        do
                /bin/sleep 30
                ${HOME}/providerscripts/datastore/config/toolkit/SyncFromConfigDatastoreWithDelete.sh "root" "/var/lib/adt-config"
				if ( [ -d /var/lib/adt-config ] )
                then
                	/usr/bin/find /var/lib/adt-config -type d -empty -delete
                fi
        done
}

monitor_for_datastore_changes &

/usr/bin/inotifywait -q -m -r -e modify,delete,create /var/lib/adt-config | while read DIRECTORY EVENT FILE 
do
	if ( [ -f ${DIRECTORY}${FILE} ] && ( [ "`/bin/echo ${FILE} | /bin/grep "^\."`" = "" ] && [ "`/bin/echo ${FILE} | /bin/grep '\~$'`" = "" ] && [ "`/bin/echo ${FILE} | /bin/grep -E '[0-9]*([0-9][0-9]*){8}$'`" = "" ] && [ "`/bin/echo ${FILE} || /bin/grep  -E '\.[a-z0-9]{8,}\.partial'`" = "" ] ) || [ "${EVENT}" = "DELETE" ]  )
	then
		case ${EVENT} in
			MODIFY*)
				file_for_processing="`/bin/echo ${DIRECTORY}${FILE} | /bin/sed 's:/var/lib/adt-config/:/var/lib/adt-config-processing/:'`"
                directory_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::'`"
                
				if ( [ ! -d ${directory_to_put} ] )
                then
                	/bin/mkdir -p ${directory_to_put}
                fi
                
				/bin/cp ${DIRECTORY}${FILE} ${directory_to_put}
				
				if ( [ "`/bin/echo ${DIRECTORY}${FILE} | /bin/sed 's:/: :g' | /usr/bin/wc -w`" -gt "4" ] )
				then
					place_to_put="`/bin/echo ${DIRECTORY}${FILE} | /bin/sed 's:/[^/]*$::' | /bin/sed 's:/var/lib/adt-config/::g'`"
				else
					place_to_put="root"
				fi
				${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh ${file_for_processing} ${place_to_put} "yes"
				;;
			CREATE*)
				file_for_processing="`/bin/echo ${DIRECTORY}${FILE} | /bin/sed 's:/var/lib/adt-config/:/var/lib/adt-config-processing/:'`"
                directory_to_put="`/bin/echo ${file_for_processing} | /bin/sed 's:/[^/]*$::'`"
                
				if ( [ ! -d ${directory_to_put} ] )
                then
                	/bin/mkdir -p ${directory_to_put}
                fi
                
				/bin/cp ${DIRECTORY}${FILE} ${directory_to_put}
				
				if ( [ "`/bin/echo ${DIRECTORY}${FILE} | /bin/sed 's:/: :g' | /usr/bin/wc -w`" -gt "4" ] )
				then
					place_to_put="`/bin/echo ${DIRECTORY}${FILE} | /bin/sed 's:/[^/]*$::' | /bin/sed 's:/var/lib/adt-config/::g'`"
				else
					place_to_put="root"
				fi
				${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh ${file_for_processing} ${place_to_put} "yes"
                ;;
			DELETE*)
                file_to_delete="`/bin/echo ${DIRECTORY}${FILE} | /bin/sed -e 's:/var/lib/adt-config/::' -e 's://:/:'`"
                ${HOME}/providerscripts/datastore/config/toolkit/DeleteFromConfigDatastore.sh "${file_to_delete}" "no" "no"
				;;
		esac
	fi
done

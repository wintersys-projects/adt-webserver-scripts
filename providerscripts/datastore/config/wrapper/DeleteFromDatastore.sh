#!/bin/sh

bucket_type="${1}"
file_to_delete="${2}"
mode="${3}"
additional_specifier="${4}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "tool" ] )
then
	${HOME}/providerscripts/datastore/operations/DeleteFromDatastore.sh "${bucket_type}" "${file_to_delete}" "${mode}" "${additional_specifier}"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "lightweight" ] ||  [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "heavyweight" ] )
then
	if ( [ -f /var/lib/adt-config/${file_to_delete} ] )
	then
		/bin/rm /var/lib/adt-config/${file_to_delete}
	fi
	if ( [ -d /var/lib/adt-config/${file_to_delete} ] )
	then
		if ( [ "${recursive}" = "yes" ] )
		then
			/bin/rm -r /var/lib/adt-config/${file_to_delete}
		else
			/bin/rmdir /var/lib/adt-config/${file_to_delete}
		fi
	fi
fi

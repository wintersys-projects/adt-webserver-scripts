
file_to_delete="${1}"
local="${2}"   #are these two needed?
recursive="${3}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "toolkit" ] )
then
	${HOME}/providerscripts/datastore/config/toolkit/DeleteFromConfigDatastore.sh "${file_to_delete}" "${local}" "${recursive}"
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

file_to_list="${1}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "toolkit" ] )
then
	if ( [ "`${HOME}/providerscripts/datastore/config/toolkit/ListFromConfigDatastore.sh "${file_to_list}"`" != "" ] )
	then
		/bin/echo "found"
	fi
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "lightweight" ] || [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "heavyweight" ] )
then
	if ( [ -f ${file_to_list} ] )
	then
		/bin/echo "found"
	fi
fi

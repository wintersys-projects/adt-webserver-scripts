file_to_list="${1}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "toolkit" ] )
then
	${HOME}/providerscripts/datastore/config/toolkit/ListFromConfigDatastore.sh "${file_to_list}"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "lightweight" ] )
then

elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "heavyweight" ] )
then

fi

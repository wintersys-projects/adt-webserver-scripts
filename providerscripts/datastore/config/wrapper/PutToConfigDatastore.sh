 file_to_put="${1}"
 place_to_put="${2}"
 delete="${3}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "toolkit" ] )
then
	${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh "${file_to_put}" "${place_to_put}" "${delete}"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "lightweight" ] )
then

elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "heavyweight" ] )
then

fi

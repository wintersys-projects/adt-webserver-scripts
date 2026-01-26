#!/bin/sh

bucket_type="${1}"
file_to_get="${2}"
destination="${3}"
additional_specifier="${4}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "tool" ] )
then
  ${HOME}/providerscripts/datastore/operations/GetFromDatastore.sh "${bucket_type}" "${file_to_get}" "${destination}" "${additional_specifier}"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "lightweight" ] || [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "heavyweight" ] )
then
  if ( [ -f /var/lib/adt-config/${file_to_get} ] )
  then
    /bin/cp /var/lib/adt-config/${file_to_get} ${place_to_put}
  fi
fi

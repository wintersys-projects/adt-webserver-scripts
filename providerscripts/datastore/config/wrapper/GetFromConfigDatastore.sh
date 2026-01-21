file_to_get="${1}"
place_to_put="${2}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "toolkit" ] )
then
  ${HOME}/providerscripts/datastore/config/toolkit/GetFromConfigDatastore.sh "${file_to_get}" "${place_to_put}"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "lightweight" ] || [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "heavyweight" ] )
then
  if ( [ -f /var/lib/adt-config/${file_to_get} ] )
  then
    /bin/cp /var/lib/adt-config/${file_to_get} ${place_to_put}
  fi
fi

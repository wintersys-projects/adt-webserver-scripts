#set -x

file_to_list="${1}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "toolkit" ] )
then
        ${HOME}/providerscripts/datastore/config/toolkit/ListFromConfigDatastore.sh "${file_to_list}"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "lightweight" ] || [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "heavyweight" ] )
then
        if ( [ -f /var/lib/adt-config/${file_to_list} ] )
        then
                /bin/ls /var/lib/adt-config/${file_to_list} | /usr/bin/awk -F'/' '{print $NF}'
        fi
fi

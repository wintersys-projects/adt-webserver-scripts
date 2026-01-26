#set -x

bucket_type="${1}"
file_to_list="${2}"
additional_specifier="${3}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "tool" ] )
then
        ${HOME}/providerscripts/datastore/operations/ListFromDatastore.sh "${bucket_type}" "${file_to_list}" "${additional_specifier}"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "lightweight" ] || [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "heavyweight" ] )
then
        if ( [ -f /var/lib/adt-config/${file_to_list} ] )
        then
                /bin/ls /var/lib/adt-config/${file_to_list} | /usr/bin/awk -F'/' '{print $NF}'
        fi
fi

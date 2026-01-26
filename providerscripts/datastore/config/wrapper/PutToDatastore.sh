#!/bin/sh

bucket_type="${1}"
file_to_put="${2}"
place_to_put="${3}"
mode="${4}"
delete="${5}"
additional_specifier="${6}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "tool" ] )
then
        ${HOME}/providerscripts/datastore/operations/PutToDatastore.sh "${bucket_type}" "${file_to_put}" "${place_to_put}" "${mode}" "${delete}" "${additional_specifier}"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "lightweight" ] ||  [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "heavyweight" ] )
then
        if ( [ -f ${file_to_put} ] )
        then
                if ( [ ! -d /var/lib/adt-config/${place_to_put} ] )
                then
                        /bin/mkdir -p /var/lib/adt-config/${place_to_put}
                fi

                /bin/cp ${file_to_put} /var/lib/adt-config/${place_to_put}

        fi
fi

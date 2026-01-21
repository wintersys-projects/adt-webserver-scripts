file_to_put="${1}"
place_to_put="${2}"
delete="${3}"

if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "DATASTORECONFIGSTYLE" | /usr/bin/awk -F':' '{print $NF}'`" = "toolkit" ] )
then
        ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh "${file_to_put}" "${place_to_put}" "${delete}"
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

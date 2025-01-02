set -x

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" != "1" ] )
then
        exit
fi

directories_to_miss="none"
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh PERSISTASSETSTOCLOUD:1`" = "1" ] )
then
        directories_to_miss="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
fi
count="0"
/bin/touch ${HOME}/runtime/updated_webroot.dat

while ( [ "${count}" -lt "12" ] )
do
        if ( [ "${directories_to_miss}" != "none" ] )
        then
                command="/usr/bin/find /var/www/html "
                command_body=""
                for directory_to_miss in ${directories_to_miss}
                do
                        command_body="${command_body} -path /var/www/html/${directory_to_miss} -prune -o "
                done
                command="${command} ${command_body} -type f -mmin -1  -print"
        else
                commans="/usr/bin/find /var/www/html -type f -mmin -1 -print"
        fi
        
        for file in `${command}`
        do
                cropped_filename="`/bin/echo ${file} | /bin/sed 's,/var/www/html/,,g'`"
                if ( [ "`/bin/grep ${file} ${HOME}/runtime/updated_webroot.dat`" = "" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${file} webroot-update/${cropped_filename}
                        if ( [ "$?" = "0" ] )
                        then
                                /bin/echo ${file} >> ${HOME}/runtime/updated_webroot.dat
                        fi
                fi
        done
        count="`/usr/bin/expr ${count} + 1`"
        /bin/sleep 5
        datastore_files="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh  webroot-update/ recursive fullpath | /usr/bin/awk '{print $NF}'`"


        for file in ${datastore_files}
        do
                cropped_filename="`/bin/echo ${file} | /bin/sed 's,.*webroot-update/,,g'`"
                if ( [ "`/bin/grep ${cropped_filename} ${HOME}/runtime/updated_webroot.dat`" = "" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh webroot-update/${cropped_filename} /var/www/html/${cropped_filename}
                fi
        done

done

if ( [ -f ${HOME}/runtime/updated_webroot.dat ] )
then
        /bin/rm ${HOME}/runtime/updated_webroot.dat
fi

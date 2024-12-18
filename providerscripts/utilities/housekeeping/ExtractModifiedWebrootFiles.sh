
directories_to_miss="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"

count="0"

while ( [ "${count}" -lt "12" ] )
do
        command="/usr/bin/find /var/www/html "
        command_body=""
        for directory_to_miss in ${directories_to_miss}
        do
                command_body="${command_body} -path /var/www/html/${directory_to_miss} -prune -o "
        done
        command="${command} ${command_body} -type f -mmin -1  -print"
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
done

if ( [ -f ${HOME}/runtime/updated_webroot.dat ] )
then
        /bin/rm ${HOME}/runtime/updated_webroot.dat
fi

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


if ( [ ! -d ${HOME}/runtime/webroot_manifests ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_manifests 
fi

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
        command="/usr/bin/find /var/www/html -type f -mmin -1 -print"
fi

count="0"

while ( [ "${count}" -lt "60" ] )
do
        machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"
        ${command} > ${HOME}/runtime/webroot_manifests/webroot_manifest-${machine_ip}
        for file in `/bin/cat ${HOME}/runtime/webroot_manifests/webroot_manifest-${machine_ip}`
        do
                file_plus_epoch="${file}:`/usr/bin/date -r ${file} +"%s`"
                if ( [ -f ${HOME}/runtime/webroot_manifests/webroot_manifest-\* ] )
                then
                        if ( [ "`/bin/grep "${file_plus_epoch}" ${HOME}/runtime/webroot_manifests/webroot_manifest-\*`" = "" ] )
                        then
                                /bin/echo ${file}:`/usr/bin/date -r ${file} +"%s"` >> ${HOME}/runtime/webroot_manifests/webroot_manifest-${machine_ip}.$$
                        fi
                fi
        done
        count="`/usr/bin/expr ${count} + 10`"

        if ( [ -f ${HOME}/runtime/webroot_manifests/webroot_manifest-${machine_ip}.$$ ] )
        then
                /bin/mv ${HOME}/runtime/webroot_manifests/webroot_manifest-${machine_ip}.$$ ${HOME}/runtime/webroot_manifests/webroot_manifest-${machine_ip}-${count}
        fi
        /bin/sleep 10
done

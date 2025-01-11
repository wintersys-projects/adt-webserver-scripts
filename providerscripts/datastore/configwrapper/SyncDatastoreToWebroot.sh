export HOME=`/bin/cat /home/homedir.dat`

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" != "1" ] )
then
        exit
fi

if ( [ ! -f ${HOME}/runtime/DATASTORE_WEBROOT_INITIALISED ] )
then
        exit
fi

export HOME=`/bin/cat /home/homedir.dat`
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
TOKEN="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1 | /usr/bin/tr '[:upper:]' '[:lower:]'`"

config_bucket="`/bin/echo "${WEBSITE_URL}"-config | /bin/sed 's/\./-/g'`-${TOKEN}"

directories_to_miss="none"
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh PERSISTASSETSTOCLOUD:1`" = "1" ] )
then
        directories_to_miss="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
fi


if ( [ ! -d ${HOME}/runtime/webroot_scratch_area ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_scratch_area 
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

${command} > ${HOME}/runtime/webroot_scratch_area/newly_updated.dat


s3cmd sync  --delete-removed --exclude-from="${HOME}/runtime/webroot_scratch_area/newly_updated.dat" s3://${config_bucket}/webroot/ /var/www/html/

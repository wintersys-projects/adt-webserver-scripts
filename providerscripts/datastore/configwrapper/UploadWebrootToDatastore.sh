export HOME=`/bin/cat /home/homedir.dat`

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" != "1" ] )
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


if ( [ "${directories_to_miss}" != "none" ] )
then
        command="/usr/bin/find /var/www/html -maxdepth 1 -mindepth 1 -type d"

        command_body=""
        for directory_to_miss in ${directories_to_miss}
        do
                command_exclusions="${command_exclusions} -not -path /var/www/html/${directory_to_miss} "
        done

        command="${command} ${command_exclusions}"
fi


for file in `/usr/bin/find /var/www/html -maxdepth 1 -mindepth 1 -type d -not -path "/var/www/html/images/*" `
do
        /usr/bin/s3cmd sync "${file}/" s3://${config_bucket}/webroot`/bin/echo ${file} | /bin/sed 's,/var/www/html,,g'`/ &
        pids="${pids} $!"
done

for pid in ${pids}
do
        wait ${pid}
done

#s3cmd sync --delete-removed /var/www/html/* s3://crew-nuocial-uk-config-xrtr/webroot/

#s3cmd sync  --delete-removed s3://crew-nuocial-uk-config-xrtr/webroot/ /var/www/html/


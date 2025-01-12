export HOME=`/bin/cat /home/homedir.dat`

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" != "1" ] )
then
        exit
fi

if ( [ ! -f ${HOME}/runtime/DATASTORE_WEBROOT_INITIALISED ] )
then
        exit
fi

WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
TOKEN="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1 | /usr/bin/tr '[:upper:]' '[:lower:]'`"

config_bucket="`/bin/echo "${WEBSITE_URL}"-config | /bin/sed 's/\./-/g'`-${TOKEN}"

directories_to_miss="none"
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh PERSISTASSETSTOCLOUD:1`" = "1" ] )
then
        directories_to_miss="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
fi

if ( [ ! -d ${HOME}/runtime/webroot_audit ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_audit
fi

for directory in ${directories_to_miss}
do
        /bin/echo "${directory}/*" >> ${HOME}/runtime/webroot_audit/directories_to_miss
done
/usr/bin/s3cmd sync  --exclude-from="${HOME}/runtime/webroot_audit/directories_to_miss" s3://${config_bucket}/webroot/ /var/www/html/

${HOME}/providerscripts/utilities/security/EnforcePermissions.sh



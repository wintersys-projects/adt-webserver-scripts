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

s3cmd sync --delete-removed /var/www/html/* s3://${config_bucket}/webroot/


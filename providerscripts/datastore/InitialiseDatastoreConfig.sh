#set -x

S3_ACCESS_KEY="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3ACCESSKEY'`"
S3_SECRET_KEY="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3SECRETKEY'`"
S3_LOCATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3LOCATION'`"
S3_HOST_BASE="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3HOSTBASE'`"


no_tokens="`/bin/echo "${S3_ACCESS_KEY}" | /usr/bin/fgrep -o '|' | /usr/bin/wc -l`"
no_tokens="`/usr/bin/expr ${no_tokens} + 1`"

count="1"

while ( [ "${count}" -le "${no_tokens}" ] )
do
        ${HOME}/providerscripts/datastore/PerformDatastoreConfig.sh "`/bin/echo "${S3_ACCESS_KEY}" | /usr/bin/cut -d "|" -f ${count}`" "`/bin/echo "${S3_SECRET_KEY}" | /usr/bin/cut -d "|" -f ${count}`" "`/bin/echo "${S3_LOCATION}" | /usr/bin/cut -d "|" -f ${count}`" "`/bin/echo "${S3_HOST_BASE}" | /usr/bin/cut -d "|" -f ${count}`" ${count}
        count="`/usr/bin/expr ${count} + 1`"
done

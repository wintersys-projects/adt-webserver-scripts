#!/bin/sh

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
directories_to_sync="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:/ /g'`"

asset_buckets=""
for directory in ${directories_to_sync}
do
	asset="`/bin/echo ${directory} | /bin/sed 's;/var/;;'`"
	asset="`/bin/echo ${asset} | /bin/sed 's;www/;;'`"
	asset="`/bin/echo ${asset} | /bin/sed 's;html/;;'`"
	asset="`/bin/echo ${asset} | /bin/sed 's;/;-;g'`"
	asset_buckets="${asset_buckets} ${asset}"
done

no_directories_to_sync="`/bin/echo ${directories_to_sync} | /usr/bin/wc -w`"

count="1"

while ( [ "${count}" -le "${no_directories_to_sync}" ] )
do
	asset_directory="`/bin/echo ${directories_to_sync} | /usr/bin/cut -d " " -f ${count}`"
	asset_bucket="`/bin/echo ${asset_buckets} | /usr/bin/cut -d " " -f ${count} | /bin/sed 's;/;-;g'`"
	asset_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's;/;-;g'`-assets-${asset_bucket}"
	${HOME}/providerscripts/datastore/MountDatastore.sh ${asset_bucket}
	${HOME}/providerscripts/datastore/SyncDatastore.sh /var/www/html/${asset_directory}/ ${asset_bucket}
	count="`/usr/bin/expr ${count} + 1`"
done
~   

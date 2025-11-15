#!/bin/sh
####################################################################################
# Description: This will store the assets files when you make a temporal backup
# of your webrooot. The assets that will be persisted to the datastore will depend on
# what PERSIST_ASSETS_TO_DATASTORE is set to as well as what DIRECTORIES_TO_MOUNT
# is set to.
# Author: Peter Winter
# Date :  9/4/2016
###################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
####################################################################################
####################################################################################
#set -x
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
directories_to_sync="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:/ /g'`"

application_asset_buckets=""
for directory in ${directories_to_sync}
do
        asset_bucket="`/bin/echo "${WEBSITE_URL}-assets-${directory}" | /bin/sed 's/\./-/g'`"
        application_asset_buckets="${application_asset_buckets} `/bin/echo ${asset_bucket} `"
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

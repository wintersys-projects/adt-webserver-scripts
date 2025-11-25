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

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:0`" = "1" ] )
then
	exit
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] )
then
	exit
fi

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
directories_to_sync="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:/ /g'`"

no_directories_to_sync="`/bin/echo ${directories_to_sync} | /usr/bin/wc -w`"
count="1"
for directory in ${directories_to_sync}
do
        if ( [ "${count}" -le "${no_directories_to_sync}" ] )
        then
                asset_bucket="`/bin/echo "${WEBSITE_URL}-assets-${directory}" | /bin/sed -e 's/\./-/g' -e 's;/;-;g' -e 's/--/-/g'`"
                echo ${asset_bucket}
                asset_directory="`/bin/echo ${directories_to_sync} | /usr/bin/cut -d " " -f ${count}`"
                echo ${asset_directory}
                ${HOME}/providerscripts/datastore/MountDatastore.sh ${asset_bucket}
                ${HOME}/providerscripts/datastore/SyncDatastore.sh /var/www/html/${asset_directory}/ ${asset_bucket}
                count="`/usr/bin/expr ${count} + 1`"
        fi
done

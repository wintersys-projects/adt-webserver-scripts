#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This will reset the historical filesystem update archives. This is done
# when a new backup of the filesystem (which then becomes the new authoritative source
# of your web application). The historical updates (additions and deletions) will be
# baked in to the backup itself so will not need to be applied separately and a new
# batch of historical update archives can be generated until the next backup is made
# and becomes authoritative. 
#####################################################################################
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

target_directory="${1}"

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
sync_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-sync-tunnel`/bin/echo ${target_directory} | /bin/sed 's:/:-:g'`"

historical_additions="`${HOME}/providerscripts/datastore/dedicated/ListFromDatastore.sh ${sync_bucket}/ffilesystem-sync/historical/additions/additions*.tar.gz`"

for addition in ${historical_additions}
do
        ${HOME}/providerscripts/datastore/dedicated/DeleteFromDatastore.sh ${sync_bucket}/filesystem-sync/historical/additions/${addition} "no" "no"
done

historical_deletions="`${HOME}/providerscripts/datastore/dedicated/ListFromDatastore.sh ${sync_bucket}/filesystem-sync/historical/deletions/deletions*.log`"

for deletion in ${historical_deletions}
do
        ${HOME}/providerscripts/datastore/dedicated/DeleteFromDatastore.sh ${sync_bucket}/filesystem-sync/historical/deletions/${deletion} "no" "no"
done

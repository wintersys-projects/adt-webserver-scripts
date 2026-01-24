#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Keep addition archives around for 5 minutes (300 seconds)
# and once these archives are more than 5 minutes old they can be deleted and the 
# historical copy will then become the authoritative archive.
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

#WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
#sync_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-sync-tunnel`/bin/echo ${target_directory} | /bin/sed 's:/:-:g'`"

additions="`${HOME}/providerscripts/datastore/dedicated/ListFromDatastore.sh "sync" "filesystem-sync/additions/additions*.tar.gz"`"

for addition in ${additions}
do
        if ( [ "`${HOME}/providerscripts/datastore/dedicated/AgeOfDatastoreFile.sh "sync" "filesystem-sync/additions/${addition}"`" -gt "60" ] )
        then
                ${HOME}/providerscripts/datastore/dedicated/DeleteFromDatastore.sh "sync" "filesystem-sync/additions/${addition}" "distributed"
        fi
done

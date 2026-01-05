#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Keep deletion archives around for 5 minutes (300 seconds)
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

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

deletions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsync/deletions/deletions*.log 2>/dev/null`"

for deletion in ${deletions}
do
        if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh webrootsync/deletions/${deletion}`" -gt "300" ] )
        then
                if ( [ "${MULTI_REGION}" != "1" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webrootsync/deletions/${deletion}
                else
                        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
                        ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${multi_region_bucket}/webrootsync/deletions/${deletion}
                fi
        fi
done

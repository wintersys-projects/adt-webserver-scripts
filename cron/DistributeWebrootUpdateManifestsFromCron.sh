#!/bin/sh
############################################################################################################
# Description: When there are updated files in the webroot of a machine and "SYNC_WEBROOTS" is set to "1", 
# this script will distribute the updated files to all other webservers. 
# Date: 16/11/2016
# Author: Peter Winter
###########################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x
if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLED_SUCCESSFULLY"`" != "1" ] )
then
	exit
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" = "1" ] )
then
	${HOME}/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "0" &
	/bin/sleep 10
	${HOME}/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "10" &
	/bin/sleep 10
	${HOME}/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "20" &
	/bin/sleep 10
	${HOME}/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "30" &
	/bin/sleep 10
	${HOME}/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "40" &
	/bin/sleep 10
	${HOME}/utilities/housekeeping/DistributeWebrootUpdatesManifests.sh "50" &
fi




#!/bin/sh
#####################################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: If we are deploying from a snapshot the application configuration may need to be 
# reset (if the new database has a different ip address to the ip address that it had when the 
# snapshot was taken), for example. This script can be called from the build machine to reset
# the configuration of the application which we trigger the the application's configuration to be
# refreshed with fresh configuration values
######################################################################################################
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
    
for applicationdir in `/bin/ls -d ${HOME}/application/configuration/*/`
do
    applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}'`"
    if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:${applicationname}`" = "1" ] )
    then
        . ${applicationdir}ResetConfiguration.sh
    fi
done

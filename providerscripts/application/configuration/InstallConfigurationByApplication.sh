#!/bin/sh
####################################################################################
# Description: This script will extract the configuration file and make it commonly
# available to all webserver instances. This means you can change the configuration
# in one place and it is reflected in all webservers
# Date: 21/11/2016
# Author: Peter Winter
####################################################################################
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
#################################################################################
#################################################################################
#set -x

for applicationdir in `/bin/ls -d ${HOME}/providerscripts/application/configuration/*/`
do
    applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}'`"
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:${applicationname}`" = "1" ] )
    then
        . ${applicationdir}InstallConfiguration.sh
    fi
done


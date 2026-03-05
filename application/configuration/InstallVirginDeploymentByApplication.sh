#!/bin/sh
######################################################################################
# Description: This script will download and install a virgin copy of an Application.
# It is expected that it will then be initialised ready for use by the initialisation script.
# Date: 16-11-2016
# Author: Peter Winter
########################################################################################
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
################################################################################
################################################################################
#set -x

APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
for applicationdir in `/bin/ls -d ${HOME}/application/configuration/*/ | /bin/sed 's;/$;;g' | /usr/bin/awk -F'/' '{print $NF}'`
do
        if ( [ "${APPLICATION}" = "${applicationdir}" ] )
        then
                ${HOME}/application/configuration/${APPLICATION}/InstallVirginDeployment.sh
                break
        fi
done


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

application="${1}"
SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"

installed="0"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] )
then
    /bin/echo ${installed}
else
    for applicationdir in `/bin/ls -d ${HOME}/providerscripts/application/configuration/*/`
    do
        applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}' | /usr/bin/tr 'a-z' 'A-Z'`"
        if ( [ "`/bin/echo ${application} | /bin/grep ${applicationname}`" != "" ] )
        then
            if ( [ "`. ${applicationdir}InstallVirginDeployment.sh`" = "1" ] )
            then
                installed="1"
            fi
            break
        fi
    done
    /bin/echo ${installed}
fi

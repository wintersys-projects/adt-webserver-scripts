#!/bin/sh
####################################################################################
# Description: This script will archive the application on an Application by Application
# basis. You can implement application specific bundling in the subdirs as per the examples
# Date: 16-11-2016
# Author: Peter Winter
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
##################################################################################
##################################################################################
#set -x

directory="$1"
MOUNTED_DIRECTORIES="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

/bin/rm -r ${directory}/tmp/* ${directory}/cache/* ${directory}/logs/* /tmp/*applicationsourcecode*

CMD="/bin/tar cPvfz /tmp/applicationsourcecode.tar.gz "
if ( [ "`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PERSISTASSETSTOCLOUD'`" = "1" ] )
then
    for mounteddirectory in ${MOUNTED_DIRECTORIES}
    do
        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "0" ] )
        then
            if ( [ ! -d ${directory}/${mounteddirectory} ] )
            then
                /bin/mkdir -p ${directory}/${mounteddirectory}
            fi
            CMD=${CMD}"--exclude=\"${directory}/${mounteddirectory}\" "
        fi
    done
fi

CMD="${CMD} ${directory}/* "

eval ${CMD}

/bin/cp /tmp/applicationsourcecode.tar.gz /tmp/${WEBSITE_NAME}-applicationsourcecode.tar.gz


#!/bin/sh
#############################################################################################################################
# Description: This script provides a common interface where you can place your application specific customisations.
# The things you need to do is make sure that the application identifier is set for your application type on the build
# client and also provider the customisation scripts in the subdirectory. There is an example one, 'socialnetwork'.
# You then customise this script to call your application specific scripts and perform application specific functions.
# Remember, if you don't set the application type on the build client, then the application will not be customised accordingly.
# If you set no application type at all, then no cusromisations will be applied.
# Date: 16-11-2016
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

for applicationdir in `/bin/ls -d ${HOME}/providerscripts/application/customise/*/`
do
    applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}'`"
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:${applicationname}`" = "1" ] )
    then
        . ${applicationdir}CustomiseApplication.sh
    fi
done

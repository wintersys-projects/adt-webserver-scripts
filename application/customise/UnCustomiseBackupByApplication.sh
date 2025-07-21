#!/bin/sh
#################################################################################
# Description: If we did any customisations to our backup, we can uncustomise it
# here which is what we do when we are building from a backup. 
# Author: Peter Winter
# Date: 05/01/2017
################################################################################
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
###############################################################################
###############################################################################
#set -x

for applicationdir in `/bin/ls -d ${HOME}/application/customise/*/`
do
	applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}'`"
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:${applicationname}`" = "1" ] )
	then
		. ${applicationdir}UnCustomiseBackup.sh
	fi
done



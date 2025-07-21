#!/bin/sh
###########################################################################################################
# Description: This will check if a recognised application has been installed
# Author : Peter Winter
# Date: 17/05/2017
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
installed="0" 

APPLICATION_IDENTIFIER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONIDENTIFIER'`"

if ( [ "${APPLICATION_IDENTIFIER}" != "0" ] )
then
	for applicationdir in `/bin/ls -d ${HOME}/application/configuration/*/`
	do
		applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}'`"
		if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:${applicationname}`" = "1" ] )
		then
			. ${applicationdir}CheckIfApplicationIsInstalled.sh
		fi
	done

	/bin/echo "${installed}"
else
	/bin/echo "1"
fi

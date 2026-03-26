#!/bin/sh
###########################################################################################################
# Description: Check if moodle is installed 
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
#set -x

installed="1"

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then	
	directories="`/bin/grep "^APPLICATION_INTEGRITY_DIRECTORIES" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_INTEGRITY_DIRECTORIES://g' | /bin/sed 's/:/ /g'`"
	for directory in ${directories}
	do
		if ( [ ! -d /var/www/html/${directory} ] )
		then
			installed="0"
		fi
	done
	
	files="`/bin/grep "^APPLICATION_INTEGRITY_FILES" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_INTEGRITY_FILES://g' | /bin/sed 's/:/ /g'`"
	for file in ${files}
	do
		if ( [ ! -f /var/www/html/${file} ] )
		then
			installed="0"
		fi
	done
fi
/bin/echo "APPLICATION_INSTALLED:${installed}"



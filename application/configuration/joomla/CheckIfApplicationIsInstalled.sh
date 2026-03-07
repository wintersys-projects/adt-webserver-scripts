#!/bin/sh
###########################################################################################################
# Description:Check if a joomla application has been installed
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

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
	#Check that the heart of the application is present increasing our confidence that the application is installed and active
	if ( [ -d /var/www/html/administrator ] && [ -d /var/www/html/modules ] && [ -d /var/www/html/plugins ] && [ -d /var/www/html/templates ] )
	then
		#Test that there is a body of files on the file system to increase our confidence further that the application is installed
		if ( [ "`/usr/bin/find /var/www/html -maxdepth 1 -type d | /usr/bin/wc -l`" -gt "5" ] && [ "`/usr/bin/find /var/www/html -type f | /usr/bin/wc -l`" -gt "5" ] )
		then
			probecount="0"
			status="down"
			file="`${HOME}/application/configuration/SelectHeadFile.sh`"
			while ( [ "${probecount}" -le "10" ] && [ "${status}" = "down" ] )
			do
				if ( [ "`/usr/bin/curl -s -m 20 --insecure -I "https://localhost:443/${file}" 2>&1 | /bin/grep "HTTP" | /bin/grep -E "200|301|302|303"`" != "" ] ) 
				then
					status="up"
    			else
					status="down"
					/bin/sleep 10
				fi
				probecount="`/usr/bin/expr ${probecount} + 1`"
			done

			if ( [ "${status}" = "up" ] )
			then
				installed="1"
			fi
		fi
	fi
fi

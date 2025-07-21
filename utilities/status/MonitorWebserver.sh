#!/bin/sh
###############################################################################################
# Description : You can run this script by modifying the token to see if your website is online or not
# Date: 16/12/2016
# Author: Peter Winter
################################################################################################
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
###########################################################################################
###########################################################################################
#set -x

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

######CHANGE THIS token AS YOU DESIRE TO BE SOMETHING YOU CAN DETECT IN YOUR WEBPAGE##########
token="MY token"

while ( [ 1 ] )
do
	/bin/sleep 1
	if ( [ "`/usr/bin/curl https://${WEBSITE_URL} | /bin/grep "${token}"`" |= "" ] )
	then
		/bin/echo "`/bin/date`:ONLINE" >> ${HOME}/logs/ONLINELOG
	else 
		/bin/echo "`/bin/date`:OFFLINE" > ${HOME}/logs/ONLINELOG
	fi
done

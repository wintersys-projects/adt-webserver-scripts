#!/bin/sh
####################################################################################
# Description: This will tell us if the webserver is fully built or not by returning "1"
# if it is and returning "0" if it isn't. 
# Date: 16/11/2016
# Author: Peter Winter
###################################################################################
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

if ( [ -f ${HOME}/runtime/INITIAL_BUILD_WEBSERVER_ONLINE ] || [ -f ${HOME}/runtime/AUTOSCALED_WEBSERVER_ONLINE ] )
then
	/bin/echo "1" 
else
	/bin/echo "0"
fi

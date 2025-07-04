#!/bin/sh
#####################################################################################
# Description: If your application requires any post processing to be performed, then,
# this is the place to put it. Post processing is considered to be any processing which
# is required after the application is considered installed. 
# Author: Peter Winter
# Date: 04/01/2017
###############################################################################################
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
#####################################################################################
#####################################################################################
set -x

#SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
#SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
#SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"
#WEBSERVER_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"

#if ( [ "${WEBSERVER_CHOICE}" = "APACHE" ] )
#then
 # if ( [ -f /var/www/html/.htaccess ] )
 # then
 #   /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /bin/sh -c '/bin/echo  "RewriteRule ^index\.php/(.*) /\$1 [R=301,L]" | /usr/bin/tee -a /var/www/html/.htaccess'
 # fi
#fi

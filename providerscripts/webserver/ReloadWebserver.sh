#!/bin/sh
#########################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script  reloads the webserver
#########################################################################################
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
#######################################################################################
#######################################################################################
#set -x

if ( [ "`/usr/bin/hostname | /bin/grep "\-auth-"`" != "" ] )
then
        WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'AUTHSERVERURL'`"
else
        WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
fi
#Prevent ourselves even trying to reload of we are not secure
if ( [ ! -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ] || [ ! -f ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ] )
then
	exit
fi

WEBSERVER_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"

if ( [ "${WEBSERVER_CHOICE}" = "NGINX" ] )
then
	${HOME}/utilities/processing/RunServiceCommand.sh nginx reload

fi
if ( [ "${WEBSERVER_CHOICE}" = "APACHE" ] )
then
	${HOME}/utilities/processing/RunServiceCommand.sh "apache2 " reload
fi
if ( [ "${WEBSERVER_CHOICE}" = "LIGHTTPD" ] )
then
	${HOME}/utilities/processing/RunServiceCommand.sh lighttpd reload
fi

#!/bin/sh
###########################################################################################################
# Description: Check if wordpress is installed 
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

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
	if ( [ -f /var/www/html/wp-login.php ] && [ -d /var/www/html/wp-content ] && [ -f /var/www/html/wp-cron.php ] && [ -d /var/www/html/wp-admin ] && [ -d /var/www/html/wp-includes ] && [ -f /var/www/html/wp-settings.php ] )
	then
		if ( [ "`/usr/bin/find /var/www/html -type d | /usr/bin/wc -l`" -gt "5" ] && [ "`/usr/bin/find /var/www/html -type f | /usr/bin/wc -l`" -gt "5" ] )
		then
			installed="1"
		fi
	fi
fi


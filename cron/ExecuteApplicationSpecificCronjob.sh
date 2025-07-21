#!/bin/sh
###########################################################################################################
# Description: Sometimes applications can require you to execute application specific cronjobs.
# When that is the case you can put those cronjobs here. I have provided a couple of example ones for you
# Date: 09/07/2022
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
#set -x


####If a specific application needs additions to crontab, you can place them here:
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
	/bin/echo "*/30 * * * * /usr/local/bin/wp cron event run --due-now --path='/var/www/html' >/dev/null 2>&1" >> /var/spool/cron/crontabs/www-data
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
	/bin/echo "*/1 * * * * /usr/bin/php /var/www/html/admin/cli/cron.php >/dev/null" > /var/spool/cron/crontabs/www-data
fi


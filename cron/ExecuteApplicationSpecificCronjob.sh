#!/bin/sh
###########################################################################################################
# Description: Sometimes applications can require you to execute application specific cronjobs.
# When that is the case you can put those cronjobs here. I have provided a couple of example ones for
# applications I was playing about with during testing, peepso from wordpress and easysocial from joomla.
# It should work similarly for any other appilcation cronjob
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


if ( [ -d /var/www/html/administrator/components/com_easysocial ] )
then
    if ( [ "`/usr/bin/crontab -l | /bin/grep 'com_easysocial'`" = "" ] )
    then
        /bin/echo "@daily  /usr/bin/sudo -u www-data /usr/bin/curl --insecure \"https://localhost:443/index.php?option=com_easysocial&cron=true\"" >> /var/spool/cron/crontabs/root
    fi
fi

if ( [ -d /var/www/html/wp-content/peepso ] )
then
    if ( [ "`/usr/bin/crontab -l | /bin/grep 'peepso'`" = "" ] )
    then
        /bin/echo "*/5 * * * * /usr/bin/sudo -u www-data /usr/bin/curl --insecure \"https://localhost:443/?peepso_process_maintenance\" > /dev/null" >> /var/spool/cron/crontabs/root
        /bin/echo "*/5 * * * * /usr/bin/sudo -u www-data /usr/bin/curl --insecure \"https://localhost:443/?peepso_process_mailqueue\" > /dev/null" >> /var/spool/cron/crontabs/root
        /bin/echo "*/15 * * * * /usr/bin/sudo -u www-data /usr/bin/curl --insecure \"https://localhost:443/?peepso_gdpr_export_data_event\" > /dev/null" >> /var/spool/cron/crontabs/root
        /bin/echo "*/15 * * * * /usr/bin/sudo -u www-data /usr/bin/curl --insecure \"https://localhost:443/?peepso_email_digest_event\" > /dev/null" >> /var/spool/cron/crontabs/root
    fi
fi

####If a specific application needs additions to crontab, you can place them here:

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    /bin/echo "*/30 * * * * /usr/local/bin/wp cron event run --due-now --path='/var/www/html' >/dev/null 2>&1" >> /var/spool/cron/crontabs/www-data
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    /bin/echo "*/1 * * * * /usr/bin/php /var/www/html/moodle/admin/cli/cron.php >/dev/null" > /var/spool/cron/crontabs/www-data
fi


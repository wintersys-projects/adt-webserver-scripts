#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will customise the nginx configuration for joomla
####################################################################################
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
#################################################################################
#################################################################################
#set -x

WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"

if ( [ "${APPLICATION}" = "moodle" ] )
then
        if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
        then
                if ( [ "`/bin/grep '/var/www/html/public' /etc/nginx/sites-available/${WEBSITE_NAME}`" = "" ] )
                then
                        /bin/sed -i 's;/var/www/html;/var/www/html/public;' /etc/nginx/sites-available/${WEBSITE_NAME}
                fi
        fi
fi

if ( [ "${APPLICATION}" = "drupal" ] )
then
        if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
        then
                if ( [ "`/bin/grep '/var/www/html/public' /etc/nginx/sites-available/${WEBSITE_NAME}`" = "" ] )
                then
                        /bin/sed -i 's;/var/www/html;/var/www/html/public;' /etc/nginx/sites-available/${WEBSITE_NAME}
                fi
        fi
fi

${HOME}/providerscripts/webserver/RestartWebserver.sh

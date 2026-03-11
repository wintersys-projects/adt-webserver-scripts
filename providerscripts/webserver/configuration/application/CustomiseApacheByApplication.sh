###########################################################################################################
# Description: This will customise that Apache configuration file for joomla
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

WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

if ( [ -f /etc/apache2/sites-available/${WEBSITE_NAME} ] )
then
        if ( [ "`/bin/grep '/var/www/html/public' /etc/apache2/sites-available/${WEBSITE_NAME}`" = "" ] )
        then
                /bin/sed -i 's;/var/www/html;/var/www/html/public;' /etc/apache2/sites-available/${WEBSITE_NAME}
        fi
fi

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
        if ( [ "`/bin/grep '/var/www/html/public' /etc/nginx/sites-available/${WEBSITE_NAME}`" = "" ] )
        then
                /bin/sed -i 's;/var/www/html;/var/www/html/public;' /etc/nginx/sites-available/${WEBSITE_NAME}
        fi
fi

if ( [ -f /etc/lighttpd/lighttpd.conf ] )
then
        if ( [ "`/bin/grep '/var/www/html/public' /etc/lighttpd/lighttpd.conf`" = "" ] )
        then
                /bin/sed -i 's;/var/www/html;/var/www/html/public;' /etc/lighttpd/lighttpd.conf
        fi
fi

${HOME}/providerscripts/webserver/RestartWebserver.sh

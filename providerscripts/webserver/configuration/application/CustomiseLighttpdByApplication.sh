#!/bin/sh
##################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will customise the lighttpd configuration for joomla installations
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
#################################################################################
#################################################################################
set -x

WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
webroot_directory="`/bin/grep "^WEBROOT_DIRECTORY:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"


if ( [ "${APPLICATION}" = "joomla" ] )
then
        if ( [ "${webroot_directory}" = "" ] )
        then
                webroot_directory="/var/www/html/joomla"
        fi
        
        if ( [ -f /etc/lighttpd/lighttpd.conf ] )
        then
                if ( [ "`/bin/grep "${webroot_directory}" /etc/lighttpd/lighttpd.conf`" = "" ] )
                then
                        /bin/sed -i "s;/var/www/html;${webroot_directory};" /etc/lighttpd/lighttpd.conf
                fi
        fi
fi

if ( [ "${APPLICATION}" = "wordpress" ] )
then
        if ( [ "${webroot_directory}" = "" ] )
        then
                webroot_directory="/var/www/html/wordpress"
        fi
        
        if ( [ -f /etc/lighttpd/lighttpd.conf ] )
        then
                if ( [ "`/bin/grep "${webroot_directory}" /etc/lighttpd/lighttpd.conf`" = "" ] )
                then
                        /bin/sed -i "s;/var/www/html;${webroot_directory};" /etc/lighttpd/lighttpd.conf
                fi
        fi
fi

if ( [ "${APPLICATION}" = "drupal" ] )
then
        if ( [ "${webroot_directory}" = "" ] )
        then
                webroot_directory="/var/www/html/drupal"
        fi
        if ( [ -f /etc/lighttpd/lighttpd.conf ] )
        then
                if ( [ "`/bin/grep "${webroot_directory}" /etc/lighttpd/lighttpd.conf`" = "" ] )
                then
                        /bin/sed -i "s;/var/www/html;${webroot_directory};" /etc/lighttpd/lighttpd.conf
                fi
        fi
fi

if ( [ "${APPLICATION}" = "moodle" ] )
then
        if ( [ "${webroot_directory}" = "" ] )
        then
                webroot_directory="/var/www/html/public"
        fi
        if ( [ -f /etc/lighttpd/lighttpd.conf ] )
        then
                if ( [ "`/bin/grep "${webroot_directory}" /etc/lighttpd/lighttpd.conf`" = "" ] )
                then
                        /bin/sed -i "s;/var/www/html;${webroot_directory};" /etc/lighttpd/lighttpd.conf
                fi
        fi
fi


${HOME}/providerscripts/webserver/RestartWebserver.sh

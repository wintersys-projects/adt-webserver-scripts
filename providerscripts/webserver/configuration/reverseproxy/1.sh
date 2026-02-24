#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This will remove a webserver IP address from the current list of active 
# webserver IP addresses in a reverse proxy machine. 
#####################################################################################
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
######################################################################################
######################################################################################
set -x

WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

if ( [ -f /etc/apache2/sites-available/${WEBSITE_NAME} ] )
then
        active_webserver_ips="`/bin/grep BalancerMember /etc/apache2/sites-available/${WEBSITE_NAME} | /usr/bin/awk -F'/' '{print $NF}' | /usr/bin/awk -F':' '{print $1}'`"
        webserver_ips="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "webserverips/*"`"

        for ip in ${active_webserver_ips}
        do
                if ( [ "`/bin/echo ${webserver_ips} | /bin/grep ${ip}`" = "" ] )
                then
                        /bin/sed -i "/${ip}/d" /etc/apache2/sites-available/${WEBSITE_NAME}
                        ${HOME}/providerscripts/webserver/ReloadWebserver.sh
                fi
        done
fi


if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
        if ( [ "`/bin/grep ${webserver_ip} /etc/nginx/sites-available/${WEBSITE_NAME}`" != "" ] )
        then
                /bin/sed -i "/${webserver_ip}/d" /etc/nginx/sites-available/${WEBSITE_NAME}
                ${HOME}/providerscripts/webserver/ReloadWebserver.sh
        fi
fi

if ( [ -f /etc/lighttpd/lighttpd.conf ] )
then
        if ( [ "`/bin/grep ${webserver_ip} /etc/lighttpd/lighttpd.conf`" != "" ] )
        then
                /bin/sed -i "/${webserver_ip}/d" /etc/lighttpd/lighttpd.conf
                ${HOME}/providerscripts/webserver/ReloadWebserver.sh
        fi
fi

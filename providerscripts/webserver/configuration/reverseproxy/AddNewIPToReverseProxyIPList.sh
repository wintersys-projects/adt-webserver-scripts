#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This will add a webserver UP address to  the current list of active 
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
#set -x

webserver_ip="${1}"

WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
php_port="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /usr/bin/awk -F'|' '{print $NF}'`"

if ( [ -f /etc/apache2/sites-available/${WEBSITE_NAME}.conf ] )
then
        if ( [ "`/bin/grep ${webserver_ip} /etc/apache2/sites-available/${WEBSITE_NAME}.conf`" = "" ] )
        then
                /bin/sed -i "/XXXXWEBSERVERIPHTTPSXXXX/a         BalancerMember https://${webserver_ip}:443/" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
                /bin/sed -i "/XXXXWEBSERVERIPPHPXXXX/a         BalancerMember fcgi://${webserver_ip}:${php_port}" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
                ${HOME}/providerscripts/webserver/ReloadWebserver.sh
        fi
fi

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
        if ( [ "`/bin/grep ${webserver_ip} /etc/nginx/sites-available/${WEBSITE_NAME}`" = "" ] )
        then
                /bin/sed -i "/XXXXWEBSERVERIPHTTPSXXXX/a         server ${webserver_ip}:443;" /etc/nginx/sites-available/${WEBSITE_NAME}
                /bin/sed -i "/XXXXWEBSERVERIPPHPXXXX/a         server ${webserver_ip}:${php_port};" /etc/nginx/sites-available/${WEBSITE_NAME}
                ${HOME}/providerscripts/webserver/ReloadWebserver.sh
        fi
fi

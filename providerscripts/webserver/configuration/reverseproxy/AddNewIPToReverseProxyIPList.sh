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

WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

webserver_ips="`${HOME}/providerscripts/datastore/operations/ListFromDatastore.sh "config" "webserverips/*"`"
updated="0"

for webserver_ip in ${webserver_ips}
do
        if ( [ -f /etc/apache2/sites-available/${WEBSITE_NAME}.conf ] )
        then
                if ( [ "`/bin/grep ${webserver_ip} /etc/apache2/sites-available/${WEBSITE_NAME}.conf`" = "" ] )
                then
                        if ( [ "`${HOME}/providerscripts/datastore/operations/ListFromDatastore.sh "config" "beingbuiltips/${webserver_ip}"`" = "" ] )
                        then
                                if ( [ "`/usr/bin/curl -m 2 --insecure -I 'https://'${webserver_ip}':443/index.php' 2>&1 | /bin/grep 'HTTP' | /bin/grep -w '200\|301\|302\|303'`" != "" ] )
                                then
                                        /bin/sed -i "/XXXXWEBSERVERIPHTTPSXXXX/a         BalancerMember https://${webserver_ip}:443" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
                                        updated="1"
                                fi
                        fi
                fi
        fi

        if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
        then
                if ( [ "`/bin/grep ${webserver_ip} /etc/nginx/sites-available/${WEBSITE_NAME}`" = "" ] )
                then
                if ( [ "`${HOME}/providerscripts/datastore/operations/ListFromDatastore.sh "config" "beingbuiltips/${webserver_ip}"`" = "" ] )
                        then
                                if ( [ "`/usr/bin/curl -m 2 --insecure -I 'https://'${webserver_ip}':443/index.php' 2>&1 | /bin/grep 'HTTP' | /bin/grep -w '200\|301\|302\|303'`" != "" ] )
                                then
                                        /bin/sed -i "/XXXXWEBSERVERIPHTTPSXXXX/a         server ${webserver_ip}:443;" /etc/nginx/sites-available/${WEBSITE_NAME}
                                        updated="1"
                                fi
                        fi
                fi
        fi
done

if ( [ "${updated}" = "1" ] )
then
        ${HOME}/providerscripts/webserver/ReloadWebserver.sh
fi


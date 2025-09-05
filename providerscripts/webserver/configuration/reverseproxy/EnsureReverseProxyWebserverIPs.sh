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
#set -x

WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
webserver_ip_removed="no"

if ( [ -f /etc/apache2/sites-available/${WEBSITE_NAME}.conf ] )
then
        if ( [ "`/bin/grep 'BalancerMember.*443' /etc/apache2/sites-available/${WEBSITE_NAME}.conf`" != "" ] )
        then
                reverse_proxy_live_ips="`/bin/grep 'BalancerMember.*443' /etc/apache2/sites-available/${WEBSITE_NAME}.conf | /bin/sed -e 's;BalancerMember.*//;;g' -e 's/:443.*//g'`"
                webserver_live_ips="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/*`"

                ips_to_remove=""
                for ip in ${reverse_proxy_live_ips}
                do
                        if ( [ "`/bin/echo ${webserver_live_ips} | /bin/grep ${ip}`" = "" ] || [ "`/usr/bin/curl -s -m 20 --insecure -I "https://${ip}:443" 2>&1 | /bin/grep "HTTP" | /bin/grep -E "200|301|302|303"`" = "" ] )
                        then
                                /bin/sed -i "/${ip}/d" /etc/apache2/sites-available/${WEBSITE_NAME}.conf
                                webserver_ip_removed="yes"
                        fi
                done
        fi
fi

if ( [ -f /etc/nginx/sites-available/${WEBSITE_NAME} ] )
then
        if ( [ "`/bin/grep 'server.*443' /etc/nginx/sites-available/${WEBSITE_NAME}`" != "" ] )
        then
                reverse_proxy_live_ips="`/bin/grep 'server.*443' /etc/nginx/sites-available/${WEBSITE_NAME} | /bin/sed -e 's/.*server //g' -e 's/:443.*//g'`"
                webserver_live_ips="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/*`"

                ips_to_remove=""
                for ip in ${reverse_proxy_live_ips}
                do
                        if ( [ "`/bin/echo ${webserver_live_ips} | /bin/grep ${ip}`" = "" ] || [ "`/usr/bin/curl -s -m 20 --insecure -I "https://${ip}:443" 2>&1 | /bin/grep "HTTP" | /bin/grep -E "200|301|302|303"`" = "" ] )
                        then
                                /bin/sed -i "/${ip}/d" /etc/nginx/sites-available/${WEBSITE_NAME}
                                webserver_ip_removed="yes"
                        fi
                done
        fi
fi

${HOME}/providerscripts/webserver/configuration/reverseproxy/AddNewIPToReverseProxyIPList.sh

if ( [ "${webserver_ip_removed}" = "yes" ] )
then
        ${HOME}/providerscripts/webserver/ReloadWebserver.sh
fi




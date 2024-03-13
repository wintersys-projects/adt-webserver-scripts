#!/bin/sh
######################################################################################
# Description: When we use a proxy service the service might rotate IP addresses that it
# connects to our orgin server from (apache or nginx) and some application have checks 
# to make sure that the requester ip hasn't changed. In such a case our application will
# fail (Joomla 4) is one example that has strict ip checking. So, we need to set the origin
# IP to be the real ip of our machine irrespective of which proxy ip address the request
# has been routed through. 
# You can find out more about this (because it stumped me for a couple of days) here:
# https://github.com/ergin/nginx-cloudflare-real-ip
# https://support.cloudflare.com/hc/en-us/articles/200170786-Restoring-original-visitor-IPs
# Date: 07/06/2021
# Author: Peter Winter
#######################################################################################
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
####################################################################################
####################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DNSCHOICE:cloudflare`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh WEBSERVERCHOICE:NGINX`" = "1" ] )
    then
        CLOUDFLARE_FILE_PATH=/etc/nginx/cloudflare

        /bin/echo "#Cloudflare" > $CLOUDFLARE_FILE_PATH;
        /bin/echo "" >> $CLOUDFLARE_FILE_PATH;
        
        /bin/echo "" >> $CLOUDFLARE_FILE_PATH;
        /bin/echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_FILE_PATH;
        
        /bin/echo "# - IPv4" >> $CLOUDFLARE_FILE_PATH;
        for i in `curl https://www.cloudflare.com/ips-v4`; do
            /bin/echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
        done

        /bin/echo "" >> $CLOUDFLARE_FILE_PATH;
        /bin/echo "# - IPv6" >> $CLOUDFLARE_FILE_PATH;
        for i in `curl https://www.cloudflare.com/ips-v6`; do
            /bin/echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
        done


    fi
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh WEBSERVERCHOICE:APACHE`" = "1" ] )
    then
        CLOUDFLARE_FILE_PATH=/etc/apache2/conf-available/remoteip.conf

        /bin/echo "#Cloudflare" > $CLOUDFLARE_FILE_PATH;
        /bin/echo "" >> $CLOUDFLARE_FILE_PATH;
    
        /bin/echo "" >> $CLOUDFLARE_FILE_PATH;
        /bin/echo "RemoteIPHeader CF-Connecting-IP" >> $CLOUDFLARE_FILE_PATH;

        /bin/echo "# - IPv4" >> $CLOUDFLARE_FILE_PATH;
        for i in `curl https://www.cloudflare.com/ips-v4`; do
            /bin/echo "RemoteIPTrustedProxy $i" >> $CLOUDFLARE_FILE_PATH;
        done

        /bin/echo "" >> $CLOUDFLARE_FILE_PATH;
        /bin/echo "# - IPv6" >> $CLOUDFLARE_FILE_PATH;
        for i in `curl https://www.cloudflare.com/ips-v6`; do
            /bin/echo "RemoteIPTrustedProxy $i" >> $CLOUDFLARE_FILE_PATH;
        done
    fi
    
fi

#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: We need to allow our autoscaler machines to bypass the guardian gateway
# otherwise, when we are checking the status of our machines we will get blocked 
# by the gateway guardian making us think the webserver is down
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
########################################################################################
########################################################################################
#set -x

if ( [ -f ${HOME}/runtime/BYPASS_PROCESSED ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DEVELOPMENT:1`" = "1" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PRODUCTION:0`" = "1" ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh WEBSERVERCHOICE:NGINX`" = "1" ] )
then
    WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
    WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
    /bin/echo "                   satisfy any;" >> /etc/nginx/sites-available/bypass_snippet.dat
    for ips in "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh autoscalerip/* | /usr/bin/tr '\n' ' '`"
    do
        for ip in ${ips}
        do 
            /bin/echo "                      allow ${ip};" >> /etc/nginx/sites-available/bypass_snippet.dat
        done
    done
    
    for ips in "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh autoscalerpublicip/* | /usr/bin/tr '\n' ' '`"
    do
        for ip in ${ips}
        do
            /bin/echo "                      allow ${ip};" >> /etc/nginx/sites-available/bypass_snippet.dat
        done
    done
    
    /bin/echo "                   deny all;" >> /etc/nginx/sites-available/bypass_snippet.dat

    if ( [ -f /etc/nginx/sites-available/bypass_snippet.dat ] )
    then
        /bin/sed -i -e '/####BYPASS####/{r /etc/nginx/sites-available/bypass_snippet.dat' -e 'd}' /etc/nginx/sites-available/${WEBSITE_NAME} 
    fi

    /bin/touch ${HOME}/runtime/BYPASS_PROCESSED
    /bin/rm /etc/nginx/sites-available/bypass_snippet.dat
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh WEBSERVERCHOICE:APACHE`" = "1" ] )
then
    WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
    for ip in "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh autoscalerip/* | /usr/bin/tr '\n' ' '`"
    do
        /bin/echo "                 <RequireAny>" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                      Require ip ${ip}" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                      Require valid-user" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                 </RequireAny>" >> /etc/apache2/sites-available/bypass_snippet.dat
    done
    
    for ip in "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh autoscalerpublicip/* | /usr/bin/tr '\n' ' '`"
    do
        /bin/echo "                 <RequireAny>" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                      Require ip ${ip}" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                      Require valid-user" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                 </RequireAny>" >> /etc/apache2/sites-available/bypass_snippet.dat
    done

    if ( [ -f /etc/apache2/sites-available/bypass_snippet.dat ] )
    then
        /bin/sed -i -e '/####BYPASS####/{r /etc/apache2/sites-available/bypass_snippet.dat' -e 'd}' /etc/apache2/sites-available/${WEBSITE_NAME} 
    fi

    /bin/touch ${HOME}/runtime/BYPASS_PROCESSED
    /bin/rm /etc/apache2/sites-available/bypass_snippet.dat
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh WEBSERVERCHOICE:LIGHTTPD`" = "1" ] )
then
    /bin/echo "\$HTTP[\"remoteip\"] !~ \"^(" >> /etc/lighttpd/bypass_snippet.dat
    
    for ips in "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh autoscalerip/* | /usr/bin/tr '\n' ' '`"
    do
        for ip in ${ips}
        do 
            /bin/echo "                      ${ip}|" >> /etc/lighttpd/bypass_snippet.dat
        done
    done
    
    for ips in "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh autoscalerpublicip/* | /usr/bin/tr '\n' ' '`"
    do
        for ip in ${ips}
        do 
            /bin/echo "                      ${ip}|" >> /etc/lighttpd/bypass_snippet.dat
        done
    done
    
    /bin/sed -i "s/|$//g" /etc/lighttpd/bypass_snippet.dat
    /bin/echo ")\$ \"{" >> /etc/lighttpd/bypass_snippet.dat  
    /bin/sed -i -e '/####BYPASS####/{r /etc/lighttpd/bypass_snippet.dat' -e 'd}' /etc/lighttpd/lighttpd.conf
    /bin/sed -i 's/####BYPASS1####/}/g' /etc/lighttpd/lighttpd.conf    
    /bin/rm /etc/lighttpd/bypass_snippet.dat
fi

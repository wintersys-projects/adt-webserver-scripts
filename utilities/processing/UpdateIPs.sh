#!/bin/sh
#############################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: If the webserver is up, write the IP of the webserver to the shared file system
#############################################################################################
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
###########################################################################################
###########################################################################################
#set -x

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"

ip="`${HOME}/utilities/processing/GetIP.sh`"
public_ip="`${HOME}/utilities/processing/GetPublicIP.sh`"

if ( [ "`/usr/bin/hostname | /bin/grep '\-rp-'`" != "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${ip} reverseproxyips "yes"
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${public_ip} reverseproxypublicips "yes"
elif ( [ "`/usr/bin/hostname | /bin/grep '^ws-'`" != "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${ip} webserverips "yes"
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${public_ip} webserverpublicips "yes"
elif ([ "`/usr/bin/hostname | /bin/grep '\-auth-'`" != "" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${ip} authenticatorip "yes"
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${public_ip} authenticatorpublicip "yes"
fi

if ( [ "${MULTI_REGION}" = "1" ] && [ ! -f ${HOME}/runtime/SHUTDOWN-INITIATED ] )
then
        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
        ${HOME}/providerscripts/datastore/PutToDatastore.sh ${public_ip} ${multi_region_bucket}/dbaas_ips "yes"
fi

if ( [ "`/usr/bin/hostname | /bin/grep '^ws-'`" != "" ] )
then
        webserver_ips="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/* | /bin/sed "s/${ip}//g" | /bin/sed 's/  / /g'`"

        if ( [ ! -d ${HOME}/runtime/otherwebserverips ] )
        then
                /bin/mkdir ${HOME}/runtime/otherwebserverips
        fi

        existing_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f`"

        for webserver_ip in `/bin/echo ${webserver_ips} | /bin/sed "s/${ip}//g"`
        do
                if ( [ ! -f ${HOME}/runtime/otherwebserverips/${webserver_ip} ] )
                then
                        /bin/touch ${HOME}/runtime/otherwebserverips/${webserver_ip}
                fi
        done

        if ( [ -f ${HOME}/runtime/otherwebserverips/${ip} ] )
        then
                /bin/rm ${HOME}/runtime/otherwebserverips/${ip}
        fi

        for webserver_ip in ${existing_webserver_ips}
        do
                if ( [ "`/bin/echo ${webserver_ips} | /bin/grep ${webserver_ip}`" = "" ] )
                then
                        if ( [ -f ${HOME}/runtime/otherwebserverips/${webserver_ip} ] )
                        then
                                /bin/rm ${HOME}/runtime/otherwebserverips/${webserver_ip} 
                        fi
                fi
        done
fi



















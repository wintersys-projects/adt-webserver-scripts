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

ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"
${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh webserverips/${ip} webserverips/${ip}

public_ip="`${HOME}/providerscripts/utilities/processing/GetPublicIP.sh`"
${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh webserverpublicips/${public_ip} webserverpublicips/${public_ip}

machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

webserver_ips="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/* | /bin/sed "s/${machine_ip}//g" | /bin/sed 's/  / /g'`"

if ( [ ! -d ${HOME}/runtime/webserverips ] )
then
  /bin/mkdir ${HOME}/runtime/webserverips
fi

existing_webserver_ips="`/usr/bin/find ${HOME}/runtime/webserverips -type f`"

for webserver_ip in ${webserver_ips}
do
  if ( [ ! -f ${HOME}/runtime/webserverips/${webserver_ip} ] )
  then
    /bin/touch ${HOME}/runtime/webserverips/${webserver_ip}
  fi
done

for webserver_ip in ${existing_webserver_ips}
do
  if ( [ "`/bin/echo ${webserver_ips} | /bin/grep ${webserver_ip}`" = "" ] )
  then
    if ( [ -f ${HOME}/runtime/webserverips/${webserver_ip} ] )
    then
      /bin/rm ${HOME}/runtime/webserverips/${webserver_ip} 
    fi
  fi
done




















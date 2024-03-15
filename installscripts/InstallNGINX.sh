#!/bin/sh
######################################################################################################
# Description: This script will install the nginx webserver
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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

if ( [ "${1}" != "" ] )
then
    buildos="${1}"
fi

apt=""
if ( [ "`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
    apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
    apt="/usr/sbin/apt-fast"
fi

if ( [ "${apt}" != "" ] )
then
    /usr/bin/systemctl disable --now apache2 2>/dev/null

    if ( [ "${buildos}" = "ubuntu" ] )
    then
        if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] )
        then
             ${HOME}/installscripts/nginx/BuildNginxFromSource.sh Ubuntu 
             /bin/touch /etc/nginx/BUILT_FROM_SOURCE
        elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:repo'`" = "1" ] )
        then
            DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install nginx
            /bin/systemctl unmask nginx.service
            /bin/touch /etc/nginx/BUILT_FROM_REPO
        fi
    fi

    if ( [ "${buildos}" = "debian" ] )
    then
        if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] )
        then
            ${HOME}/installscripts/nginx/BuildNginxFromSource.sh Debian        
            /bin/touch /etc/nginx/BUILT_FROM_SOURCE
        elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:repo'`" = "1" ] )
        then    
            DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install nginx
            /bin/systemctl unmask nginx.service
            /bin/touch /etc/nginx/BUILT_FROM_REPO
        fi
    fi
fi


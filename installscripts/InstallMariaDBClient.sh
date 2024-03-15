#!/bin/sh
######################################################################################################
# Description: This script will install the maria db client
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
    if ( [ "${buildos}" = "ubuntu" ] )
    then
        version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "MARIADB" | /usr/bin/awk -F':' '{print $NF}'`"
        /usr/bin/curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-${version}"
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=69  -qq -y install mariadb-client
    
        if ( [ -f /usr/bin/mysql ] )
        then
            /bin/rm /usr/bin/mysql
        fi
    
        /bin/ln -s /usr/bin/mariadb /usr/bin/mysql
    fi

    if ( [ "${buildos}" = "debian" ] )
    then
        version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "MARIADB" | /usr/bin/awk -F':' '{print $NF}'`"
        /usr/bin/curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-${version}"
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=60  -qq -y install mariadb-client
    
        if ( [ -f /usr/bin/mysql ] )
        then
            /bin/rm /usr/bin/mysql
        fi
    
        /bin/ln -s /usr/bin/mariadb /usr/bin/mysql
    fi
fi

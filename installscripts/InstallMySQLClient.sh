#!/bin/sh
###################################################################################
# Description: This  will install the mysql client
# Date: 18/11/2016
# Author : Peter Winter
###################################################################################
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
        mysql_apt_config="`/usr/bin/wget -O- https://dev.mysql.com/downloads/repo/apt/ | /bin/grep -o mysql-apt-config.* | /usr/bin/head -1 | /bin/sed 's/deb.*/deb/g'`"
        /usr/bin/wget https://dev.mysql.com/get/${mysql_apt_config} 
        DEBIAN_FRONTEND=noninteractive /usr/bin/dpkg -i ${mysql_apt_config}
        /bin/rm ${mysql_apt_config}
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=60 -qq -y install mysql-client
    fi

    if ( [ "${buildos}" = "debian" ] )
    then
        mysql_apt_config="`/usr/bin/wget -O- https://dev.mysql.com/downloads/repo/apt/ | /bin/grep -o mysql-apt-config.* | /usr/bin/head -1 | /bin/sed 's/deb.*/deb/g'`"
        /usr/bin/wget https://dev.mysql.com/get/${mysql_apt_config} 
        DEBIAN_FRONTEND=noninteractive /usr/bin/dpkg -i ${mysql_apt_config}
        /bin/rm ${mysql_apt_config}
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=60 -qq -y install mysql-client
    fi
fi

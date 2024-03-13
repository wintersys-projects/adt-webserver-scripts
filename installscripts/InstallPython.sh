#!/bin/sh
######################################################################################################
# Description: This script will install the python date util
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
set -x

if ( [ "${1}" != "" ] )
then
    buildos="${1}"
fi

if ( [ "${buildos}" = "ubuntu" ] )
then
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -qq -y install python3.8
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -qq -y install libfcgi fcgiwrap spawn-fcgi
    /usr/bin/ln /usr/bin/python3 /usr/bin/python
fi

if ( [ "${buildos}" = "debian" ] )
then
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -qq -y install build-essential
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -qq -y install libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev zlib1g
    /usr/bin/wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz
    /bin/tar xzf Python-3.7.2.tgz
    cd Python-3.7.2
    ./configure --with-ensurepip=install
    make
    make install
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -qq -y install libfcgi fcgiwrap spawn-fcgi
    /usr/bin/ln /usr/bin/python3 /usr/bin/python
fi

#!/bin/sh
###############################################################################################
# Description: This will install Goofys
# Author: Peter Winter
# Date: 12/01/2017
###############################################################################################
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
################################################################################################
################################################################################################

if ( [ "${1}" != "" ] )
then
    buildos="${1}"
fi

if ( [ "${buildos}" = "ubuntu" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'GOOF:binaries'`" = "1" ] )
    then
        /usr/bin/wget https://github.com/kahing/goofys/releases/latest/download/goofys
        /bin/mv goofys /usr/bin
        /bin/chmod 755 /usr/bin/goofys
    elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'GOOF:source'`" = "1" ] )
    then
        ${HOME}/installscripts/InstallGo.sh ${buildos}
        DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -qq -y install make
        /usr/bin/git clone https://github.com/kahing/goofys.git
        cd goofys
        make install
        goofys="`/usr/bin/find / -type f -name "goofys" -print`"
        /bin/mv ${goofys} /usr/bin
        /bin/chmod 755 /usr/bin/goofys
        cd ..
        rm -r ./goofys
    fi
fi

if ( [ "${buildos}" = "debian" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'GOOF:binaries'`" = "1" ] )
    then
        /usr/bin/wget https://github.com/kahing/goofys/releases/latest/download/goofys
        /bin/mv goofys /usr/bin
        /bin/chmod 755 /usr/bin/goofys
    elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'GOOF:source'`" = "1" ] )
    then
        ${HOME}/installscripts/InstallGo.sh ${buildos}
        DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -qq -y install make
        /usr/bin/git clone https://github.com/kahing/goofys.git
        cd goofys
        make install
        goofys="`/usr/bin/find / -type f -name "goofys" -print`"
        /bin/mv ${goofys} /usr/bin
        /bin/chmod 755 /usr/bin/goofys
        cd ..
        rm -r ./goofys
    fi
fi

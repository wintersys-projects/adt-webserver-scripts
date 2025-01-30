#!/bin/sh
######################################################################################################
# Description: This script will perform a software update
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

if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
    if ( [ "${buildos}" = "ubuntu" ] )
    then
        /usr/bin/yes | /usr/bin/dpkg --configure -a
        DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 install -y -qq apt-utils
        /bin/sed -i "s/digitalocean/linode/g" /etc/apt/sources.list.d/ubuntu.sources
        DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y update --allow-change-held-packages 
    fi

    if ( [ "${buildos}" = "debian" ] )
    then
        /usr/bin/yes | /usr/bin/dpkg --configure -a
        DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 install -y -qq apt-utils
        /bin/sed -i "s/digitalocean/linode/g" /etc/apt/mirrors/debian.list
        DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y update --allow-change-held-packages  
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
    while ( [ ! -h /usr/sbin/apt-fast ] )
    do
        if ( [ "${buildos}" = "ubuntu" ] )
        then
                ${HOME}/installscripts/AptFastInstallHelper.sh
                /usr/bin/ln -s /usr/local/bin/apt-fast /usr/sbin/apt-fast
                /bin/sed -i "s/digitalocean/linode/g" /etc/apt/sources.list.d/ubuntu.sources

                DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y update

                while ( [ "$?" != "0" ] )
                do
                    /bin/sleep 5
                    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y update
                done

                ${HOME}/installscripts/InstallAria2.sh "ubuntu"
                /bin/touch /tmp/apt-fast.list
                /bin/sed -i 's/^#DOWNLOADBEFORE/DOWNLOADBEFORE/g' /etc/apt-fast.conf
                if ( [ "${CLOUDHOST}" = "digitalocean" ] )
                then
                    /bin/echo "MIRRORS=( 'mirrors.linode.com' )" >> /etc/apt-fast.conf
                fi
                if ( [ "${CLOUDHOST}" = "linode" ] )
                then
                    /bin/echo "MIRRORS=( 'mirrors.linode.com' )" >> /etc/apt-fast.conf
                fi
        fi
    
        if ( [ "${buildos}" = "debian" ] )
        then
                ${HOME}/installscripts/AptFastInstallHelper.sh
                /usr/bin/ln -s /usr/local/bin/apt-fast /usr/sbin/apt-fast
                /bin/sed -i "s/digitalocean/linode/g" /etc/apt/mirrors/debian.list

                DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y update

                while ( [ "$?" != "0" ] )
                do
                    /bin/sleep 5
                    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y update
                done                 

                ${HOME}/installscripts/InstallAria2.sh "debian"

                /bin/touch /tmp/apt-fast.list
                /bin/sed -i 's/^#DOWNLOADBEFORE/DOWNLOADBEFORE/g' /etc/apt-fast.conf
                if ( [ "${CLOUDHOST}" = "digitalocean" ] )
                then
                    /bin/echo "MIRRORS=( 'mirrors.linode.com' )" >> /etc/apt-fast.conf
                fi
                if ( [ "${CLOUDHOST}" = "linode" ] )
                then
                    /bin/echo "MIRRORS=( 'mirrors.linode.com' )" >> /etc/apt-fast.conf
                fi
        fi
    done
fi

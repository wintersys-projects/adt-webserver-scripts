#!/bin/sh
######################################################################################################
# Description: This script will install mergerfs
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
#set -x

if ( [ "${1}" != "" ] )
then
        buildos="${1}"
fi

if ( [ "${buildos}" = "" ] )
then
        BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
else 
        BUILDOS="${buildos}"
fi
HOME="`/bin/cat /home/homedir.dat`"

mergerfs_version="`${HOME}/utilities/config/ExtractBuildStyleValues.sh 'MERGEFILESYSTEMSTOOL' | /usr/bin/awk -F':' '{print $NF}' | /bin/grep -Eo "([0-9]{1,}\.)+[0-9]{1,}"`"

if ( [ "${mergerfs_version}" = "" ] )
then
        mergerfs_version="2.41.0"
fi

apt=""
if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
        apt="/usr/bin/apt"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-get" ] )
then
        apt="/usr/bin/apt-get"
fi

export DEBIAN_FRONTEND=noninteractive
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install "

if ( [ "${apt}" != "" ] )
then
        if ( [ "${BUILDOS}" = "ubuntu" ] )
        then
                if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'MERGEFILESYSTEMSTOOL:mergefs:repo'`" = "1" ]  )
                then
                        ${HOME}/installscripts/InstallFuse3.sh ubuntu
                        eval ${install_command} mergerfs
                elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'MERGEFILESYSTEMSTOOL:mergefs:binary'`" = "1" ]  )
                then
                        ${HOME}/installscripts/InstallFuse3.sh debian
                        cwd="`/usr/bin/pwd`"
                        cd /opt
                        /usr/bin/wget https://github.com/trapexit/mergerfs/releases/download/${mergerfs_version}/mergerfs_${mergerfs_version}.ubuntu-`${HOME}/utilities/software/GetOSName.sh`_amd64.deb
                        /usr/bin/dpkg -i mergerfs_${mergerfs_version}.ubuntu-`${HOME}/utilities/software/GetOSName.sh`_amd64.deb
                        /bin/rm ./mergerfs_${mergerfs_version}.ubuntu-`${HOME}/utilities/software/GetOSName.sh`_amd64.deb
                        cd ${cwd}
                fi
        fi

        if ( [ "${BUILDOS}" = "debian" ] )
        then
                if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'MERGEFILESYSTEMSTOOL:mergefs:repo'`" = "1" ]  )
                then
                        ${HOME}/installscripts/InstallFuse3.sh debian
                        eval ${install_command} mergerfs
                elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'MERGEFILESYSTEMSTOOL:mergefs:binary'`" = "1" ]  )
                then
                        ${HOME}/installscripts/InstallFuse3.sh debian
                        cwd="`/usr/bin/pwd`"
                        cd /opt
                        /usr/bin/wget https://github.com/trapexit/mergerfs/releases/download/${mergerfs_version}/mergerfs_${mergerfs_version}.debian-`${HOME}/utilities/software/GetOSName.sh`_amd64.deb
                        /usr/bin/dpkg -i mergerfs_${mergerfs_version}.debian-`${HOME}/utilities/software/GetOSName.sh`_amd64.deb
                        /bin/rm ./mergerfs_${mergerfs_version}.debian-`${HOME}/utilities/software/GetOSName.sh`_amd64.deb
                        cd ${cwd}
                fi
        fi
fi

if ( [ ! -f /usr/bin/mergerfs ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR MERGERFS" "I believe that mergerfs hasn't installed correctly, please investigate" "ERROR"
else
        /bin/touch ${HOME}/runtime/installedsoftware/InstallMergerFS.sh
fi

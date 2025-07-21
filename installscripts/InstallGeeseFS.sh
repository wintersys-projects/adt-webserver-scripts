#!/bin/sh 
###############################################################################################
# Description: This will install Geesefs
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

cwd="`/usr/bin/pwd`"

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
	if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:binary'`" = "1" ] )
	then
		/usr/bin/wget https://github.com/yandex-cloud/geesefs/releases/latest/download/geesefs-linux-amd64 -O /usr/bin/geesefs
		/bin/chmod 755 /usr/bin/geesefs
	elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:source'`" = "1" ] )
	then
		${HOME}/installscripts/InstallGo.sh ${BUILDOS}
		cd /opt
		/usr/bin/git clone https://github.com/yandex-cloud/geesefs
		cd geesefs
		/usr/bin/go build
		/bin/cp ./geesefs /usr/bin/geesefs
		cd ..
		/bin/rm -r geesefs
		cd ${cwd}
	fi
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
	if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:binary'`" = "1" ] )
	then
		/usr/bin/wget https://github.com/yandex-cloud/geesefs/releases/latest/download/geesefs-linux-amd64 -O /usr/bin/geesefs
		/bin/chmod 755 /usr/bin/geesefs
	elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:source'`" = "1" ] )
	then
		${HOME}/installscripts/InstallGo.sh ${BUILDOS}
		cd /opt
		/usr/bin/git clone https://github.com/yandex-cloud/geesefs
		cd geesefs
		/usr/bin/go build
		/bin/cp ./geesefs /usr/bin/geesefs
		cd ..
		/bin/rm -r geesefs
		cd ${cwd}
	fi	
fi

if ( [ ! -f /usr/sbin/geesefs ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR GEESEFS" "I believe that geesefs hasn't installed correctly, please investigate" "ERROR"
else
	/bin/touch ${HOME}/runtime/installedsoftware/InstallGeeseFS.sh	
fi

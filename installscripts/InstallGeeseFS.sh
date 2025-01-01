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

if ( [ "${1}" != "" ] )
then
	buildos="${1}"
fi

apt=""
if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	apt="/usr/sbin/apt-fast"
fi

if ( [ "${apt}" != "" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:binary'`" = "1" ] )
		then
  			/usr/bin/wget https://github.com/yandex-cloud/geesefs/releases/latest/download/geesefs-linux-amd64
			/bin/mv geesefs-linux-amd64 /usr/sbin/geesefs
			/bin/chmod 755 /usr/sbin/geesefs									
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:source'`" = "1" ] )
		then
                        cwd="`/usr/bin/pwd`"
                        /usr/bin/git clone https://github.com/yandex-cloud/geesefs
                        cd geesefs
                        /usr/bin/go build
                        if ( [ -f ./geesefs ] )
                        then
                                /bin/cp ./geesefs /usr/sbin
				/bin/chmod 755 /usr/sbin/geesefs	
                        fi
                        cd ${cwd}
                        /bin/rm -r ./geesefs
		fi
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:binary'`" = "1" ] )
		then
  			/usr/bin/wget https://github.com/yandex-cloud/geesefs/releases/latest/download/geesefs-linux-amd64
			/bin/mv geesefs-linux-amd64 /usr/sbin/geesefs
			/bin/chmod 755 /usr/sbin/geesefs	
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:geesefs:source'`" = "1" ] )
		then
                        cwd="`/usr/bin/pwd`"
                        /usr/bin/git clone https://github.com/yandex-cloud/geesefs
                        cd geesefs
                        /usr/bin/go build
                        if ( [ -f ./geesefs ] )
                        then
                                /bin/cp ./geesefs /usr/sbin
				/bin/chmod 755 /usr/sbin/geesefs	
                        fi
                        cd ${cwd}
                        /bin/rm -r ./geesefs
		fi	
        fi
	/bin/touch ${HOME}/runtime/installedsoftware/InstallGeeseFS.sh			
fi
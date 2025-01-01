#!/bin/sh
######################################################################################################
# Description: This script will install the lighttpd webserver
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
if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	apt="/usr/sbin/apt-fast"
fi

install_command="DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 

if ( [ "${apt}" != "" ] )
then
	/usr/bin/systemctl disable --now apache2 2>/dev/null
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] )
		then
  			if ( [ ! -f /etc/lighttpd/BUILT_FROM_SOURCE ] )
     			then
				${HOME}/installscripts/lighttpd/BuildLighttpdFromSource.sh 		
				/bin/touch /etc/lighttpd/BUILT_FROM_SOURCE				
    			fi
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:repo'`" = "1" ] )
		then
			${install_command} lighttpd	
   			/bin/touch /etc/lighttpd/BUILT_FROM_REPO						
		fi
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] )
		then
    			if ( [ ! -f /etc/lighttpd/BUILT_FROM_SOURCE ] )
     			then
				${HOME}/installscripts/lighttpd/BuildLighttpdFromSource.sh 		
				/bin/touch /etc/lighttpd/BUILT_FROM_SOURCE				
    			fi
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:repo'`" = "1" ] )
		then
			${install_command} lighttpd
   			/bin/touch /etc/lighttpd/BUILT_FROM_REPO						
		fi
	fi
      	/bin/touch ${HOME}/runtime/installedsoftware/InstallLighttpd.sh				
fi


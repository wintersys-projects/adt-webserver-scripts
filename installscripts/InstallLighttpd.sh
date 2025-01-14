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

export DEBIAN_FRONTEND=noninteractive
update_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y update " 
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 
 

/usr/bin/systemctl disable apache2 && /usr/bin/systemctl stop apache2 2>/dev/null

if ( [ "${apt}" != "" ] )
then
	/usr/bin/systemctl disable --now apache2 2>/dev/null
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		${HOME}/installscripts/PurgeApache.sh

		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] )
		then
  			if ( [ ! -f /etc/lighttpd/BUILT_FROM_SOURCE ] )
     			then
				${update_command} 
        			#${install_command} autoconf automake libtool m4 pkg-config build-essential libpcre3-dev libpcre2-dev zlib1g zlib1g-dev libssl-dev libgnutls28-dev
    				software_package_list="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:software-packages" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/software-packages//g' | /bin/sed 's/^ //g'`"
				if ( [ "${software_package_list}" != "" ] )
    				then
					${install_command} ${software_package_list}
     				fi
				${HOME}/installscripts/lighttpd/BuildLighttpdFromSource.sh 		
    			fi
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:repo'`" = "1" ] )
		then
			${install_command} lighttpd	
   			/bin/touch /etc/lighttpd/BUILT_FROM_REPO
            		/bin/touch ${HOME}/runtime/installedsoftware/InstallLighttpd.sh				
		fi
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
		${HOME}/installscripts/PurgeApache.sh

  		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] )
		then
    			if ( [ ! -f /etc/lighttpd/BUILT_FROM_SOURCE ] )
     			then
				${update_command} 
        			#${install_command} autoconf automake libtool m4 pkg-config build-essential libpcre3-dev libpcre2-dev zlib1g zlib1g-dev  libssl-dev libgnutls28-dev
    				software_package_list="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:software-packages" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/software-packages//g' | /bin/sed 's/^ //g'`"
				if ( [ "${software_package_list}" != "" ] )
    				then
					${install_command} ${software_package_list}
     				fi			
	${HOME}/installscripts/lighttpd/BuildLighttpdFromSource.sh 		
    			fi
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:repo'`" = "1" ] )
		then
			${install_command} lighttpd
   			/bin/touch /etc/lighttpd/BUILT_FROM_REPO
            		/bin/touch ${HOME}/runtime/installedsoftware/InstallLighttpd.sh				
		fi
	fi
fi


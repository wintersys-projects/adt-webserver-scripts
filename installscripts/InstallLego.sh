#!/bin/sh
######################################################################################################
# Description: This script will install lego
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

apt=""
if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	apt="/usr/sbin/apt-fast"
fi

export DEBIAN_FRONTEND=noninteractive 
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 

if ( [ "${apt}" != "" ] )
then
	if ( [ "${BUILDOS}" = "ubuntu" ] )
	then
		eval ${install_command} jq 			
		version="`/usr/bin/curl -L https://api.github.com/repos/go-acme/lego/releases/latest | /usr/bin/jq -r '.name'`" 
		if ( [ -f /usr/bin/lego ] )                                                                                     
		then                                                                                                           
			/bin/rm /usr/bin/lego                                                                                   
		fi                                                                                                              
		/usr/bin/wget -c https://github.com/xenolf/lego/releases/download/${version}/lego_${version}_linux_amd64.tar.gz -O- | /usr/bin/tar -xz -C /usr/bin      
	fi

	if ( [ "${BUILDOS}" = "debian" ] )
	then
		eval ${install_command} jq        	
		version="`/usr/bin/curl -L https://api.github.com/repos/go-acme/lego/releases/latest | /usr/bin/jq -r '.name'`" 
		if ( [ -f /usr/bin/lego ] )                                                                                     
		then                                                                                                            
			/bin/rm /usr/bin/lego                                                                                   
		fi                                                                                                              
		/usr/bin/wget -c https://github.com/xenolf/lego/releases/download/${version}/lego_${version}_linux_amd64.tar.gz -O- | /usr/bin/tar -xz -C /usr/bin     
	fi				
fi

if ( [ ! -f /usr/bin/lego ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR LEGO" "I believe that lego hasn't installed correctly, please investigate" "ERROR"
else
	/bin/touch ${HOME}/runtime/installedsoftware/InstallLego.sh					
fi

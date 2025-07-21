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
update_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y update " 
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 

/usr/bin/systemctl disable apache2 && /usr/bin/systemctl stop apache2 2>/dev/null

if ( [ "${apt}" != "" ] )
then
	/usr/bin/systemctl disable --now apache2 2>/dev/null
	if ( [ "${BUILDOS}" = "ubuntu" ] )
	then
		if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD" | /usr/bin/awk -F':' '{print $NF}'`" != "cloud-init" ] )
		then
			${HOME}/installscripts/PurgeApache.sh

			if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] )
			then
				if ( [ ! -f /etc/lighttpd/BUILT_FROM_SOURCE ] )
				then
					eval ${update_command} 
					software_package_list="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:software-packages" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/software-packages//g' | /bin/sed 's/^ //g'`"
					if ( [ "${software_package_list}" != "" ] )
					then
						eval ${install_command} ${software_package_list}
					fi
					${HOME}/installscripts/lighttpd/BuildLighttpdFromSource.sh 		
				fi
			elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:repo'`" = "1" ] )
			then
				eval ${install_command} lighttpd	
				/bin/touch /etc/lighttpd/BUILT_FROM_REPO
			fi
		fi
	fi

	if ( [ "${BUILDOS}" = "debian" ] )
	then
		if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD" | /usr/bin/awk -F':' '{print $NF}'`" != "cloud-init" ] )
		then
			${HOME}/installscripts/PurgeApache.sh

			if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] )
			then
				if ( [ ! -f /etc/lighttpd/BUILT_FROM_SOURCE ] )
				then
					eval ${update_command} 
					software_package_list="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:software-packages" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/software-packages//g' | /bin/sed 's/^ //g'`"
					if ( [ "${software_package_list}" != "" ] )
					then
						eval ${install_command} ${software_package_list}
					fi			
					${HOME}/installscripts/lighttpd/BuildLighttpdFromSource.sh 		
				fi
			elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:repo'`" = "1" ] )
			then
				eval ${install_command} lighttpd
				/bin/touch /etc/lighttpd/BUILT_FROM_REPO
			fi
		fi
	fi
fi

if ( [ ! -f /usr/sbin/lighttpd ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR LIGHTTPD" "I believe that lighttpd hasn't installed correctly, please investigate" "ERROR"
else
	/bin/touch ${HOME}/runtime/installedsoftware/InstallLighttpd.sh					
fi


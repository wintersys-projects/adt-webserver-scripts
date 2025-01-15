#!/bin/sh
######################################################################################################
# Description: This script will install the apache webserver
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

PHP_VERSION="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"

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


if ( [ "${apt}" != "" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
   
		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:source'`" = "1" ] )
		then
  			if ( [ ! -f /etc/apache2/BUILT_FROM_SOURCE ] )
     			then
				#${install_command} pandoc build-essential libssl-dev libexpat-dev libpcre3-dev libapr1-dev libaprutil1-dev libnghttp2-dev
    		     		
				${HOME}/installscripts/PurgeApache.sh
	 			
     				software_package_list="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "APACHE:software-packages" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/software-packages//g' | /bin/sed 's/^ //g'`"
				if ( [ "${software_package_list}" != "" ] )
    				then
					${install_command} ${software_package_list}
     				fi			
	#${HOME}/installscripts/apache/BuildApacheFromSource.sh  "Ubuntu" 		
    			fi
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:repo'`" = "1" ] )
		then
  
				${install_command} apache2    	
				${install_command} apache2-utils    
		
				if ( [  "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
				then
					${install_command} libapache2-mod-php 
				fi
    		
		     	/bin/touch ${HOME}/runtime/installedsoftware/InstallApache.sh				

			/bin/touch /etc/apache2/BUILT_FROM_REPO
		fi    
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
 
		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:source'`" = "1" ] )
		then
    			if ( [ ! -f /etc/apache2/BUILT_FROM_SOURCE ] )
     			then
				${HOME}/installscripts/PurgeApache.sh

				#${install_command} pandoc build-essential libssl-dev libexpat-dev libpcre3-dev libapr1-dev libaprutil1-dev libnghttp2-dev	
    				software_package_list="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "APACHE:software-packages" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/software-packages//g' | /bin/sed 's/^ //g'`"
				if ( [ "${software_package_list}" != "" ] )
    				then
					${install_command} ${software_package_list}
     				fi
				${HOME}/installscripts/apache/BuildApacheFromSource.sh  "Debian" 	
    			fi
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:repo'`" = "1" ] )
		then
  

				${install_command} apache2		
				${install_command} apache2-utils   

				if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
				then
					${install_command} libapache2-mod-php 
				fi
    			
		#     	/bin/touch ${HOME}/runtime/installedsoftware/InstallApache.sh				

			/bin/touch /etc/apache2/BUILT_FROM_REPO
		fi
	fi
fi


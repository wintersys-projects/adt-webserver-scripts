#!/bin/sh
######################################################################################################
# Description: This script will install the nginx webserver
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

/usr/bin/systemctl disable apache2 && /usr/bin/systemctl stop apache2 2>/dev/null

export DEBIAN_FRONTEND=noninteractive
update_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y update " 
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 
autoremove_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y autoremove " 
remove_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y remove " 

if ( [ "${apt}" != "" ] )
then
	/usr/bin/systemctl disable --now apache2 2>/dev/null

	if ( [ "${buildos}" = "ubuntu" ] )
	then
 		${autoremove_command}
		${remove_command} "apache2*"
		
  		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] )
		then
    			if ( [ ! -f /etc/nginx/BUILT_FROM_SOURCE ] )
     			then
				#${install_command} build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev
     				#${install_command} build-essential libpcre3-dev libssl-dev zlib1g-dev libgd-dev
	     			software_package_list="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "NGINX:software-packages" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/software-packages//g' | /bin/sed 's/^ //g'`"
				if ( [ "${software_package_list}" != "" ] )
    				then
					${install_command} ${software_package_list}
     				fi
	 			${HOME}/installscripts/nginx/BuildNginxFromSource.sh "Ubuntu"  			
     			fi
	      		#Make sure nginx avaiable as a service and enable and start it
			if ( [ ! -f /lib/systemd/system/nginx.service ] )
   			then
				/bin/cp ${HOME}/installscripts/nginx/nginx.service /lib/systemd/system/nginx.service
				/usr/bin/systemctl enable nginx
    				/usr/bin/systemctl restart nginx
    			fi
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'NGINX:repo'`" = "1" ] )
		then

				${install_command} nginx	
				/bin/systemctl unmask nginx.service							
			      	/bin/touch ${HOME}/runtime/installedsoftware/InstallNGINX.sh
   			/bin/touch /etc/nginx/BUILT_FROM_REPO							
		fi
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
 		${autoremove_command}
		${remove_command} "apache2*"
		
  		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] )
		then
  			if ( [ ! -f /etc/nginx/BUILT_FROM_SOURCE ] )
     			then
    				#${install_command} build-essential libpcre3-dev libssl-dev zlib1g-dev libgd-dev
	    			software_package_list="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "NGINX:software-packages" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/software-packages//g' | /bin/sed 's/^ //g'`"
				if ( [ "${software_package_list}" != "" ] )
    				then
					${install_command} ${software_package_list}
     				fi
				${HOME}/installscripts/nginx/BuildNginxFromSource.sh "Debian"        		
    			fi
      			 #Make sure nginx avaiable as a service and enable and start it
			if ( [ ! -f /lib/systemd/system/nginx.service ] )
   			then
				/bin/cp ${HOME}/installscripts/nginx/nginx.service /lib/systemd/system/nginx.service
				/usr/bin/systemctl enable nginx
				/usr/bin/systemctl restart nginx
    			fi
    
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'NGINX:repo'`" = "1" ] )
		then   
				${install_command} nginx	
				/bin/systemctl unmask nginx.service							
			      	/bin/touch ${HOME}/runtime/installedsoftware/InstallNGINX.sh
   			/bin/touch /etc/nginx/BUILT_FROM_REPO						
		fi
	fi
				
fi


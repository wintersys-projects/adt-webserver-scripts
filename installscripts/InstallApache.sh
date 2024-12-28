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

if ( [ "${apt}" != "" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
   
		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:source'`" = "1" ] )
		then
  			if ( [ ! -f /etc/apache2/BUILT_FROM_SOURCE ] )
     			then
				${HOME}/installscripts/apache/BuildApacheFromSource.sh  Ubuntu 			#####UBUNTU-APACHE-SOURCE-INLINE#####
				/bin/touch /etc/apache2/BUILT_FROM_SOURCE					#####UBUNTU-APACHE-SOURCE#####
    			fi
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:repo'`" = "1" ] )
		then
  
  			if ( [ -f ${HOME}/rutime/APT-SINGLE ] )
     			then
				/bin/echo " apache2 apache2-utils libapache2-mod-php" >> ${HOME}/runtime/apt-install-list.dat
    			fi
       
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install apache2    	#####UBUNTU-APACHE-REPO#####
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install apache2-utils    #####UBUNTU-APACHE-REPO#####
		
			if ( [  "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
			then
				DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install libapache2-mod-php #####UBUNTU-APACHE-REPO#####
			fi
		
			/bin/touch /etc/apache2/BUILT_FROM_REPO
		fi    
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
 
		if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:source'`" = "1" ] )
		then
    			if ( [ ! -f /etc/apache2/BUILT_FROM_SOURCE ] )
     			then
				${HOME}/installscripts/apache/BuildApacheFromSource.sh  Debian		#####DEBIAN-APACHE-SOURCE-INLINE#####
				/bin/touch /etc/apache2/BUILT_FROM_SOURCE				#####DEBIAN-APACHE-SOURCE#####
    			fi
		elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:repo'`" = "1" ] )
		then
  
    			if ( [ -f ${HOME}/rutime/APT-SINGLE ] )
     			then
				/bin/echo " apache2 apache2-utils libapache2-mod-php" >> ${HOME}/runtime/apt-install-list.dat
    			fi
       
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install apache2		#####DEBIAN-APACHE-REPO#####
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install apache2-utils    #####DEBIAN-APACHE-REPO#####

			if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
			then
				DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install libapache2-mod-php #####DEBIAN-APACHE-REPO#####
			fi
		
			/bin/touch /etc/apache2/BUILT_FROM_REPO
		fi
	fi
     	/bin/touch ${HOME}/runtime/installedsoftware/InstallApache.sh				
fi


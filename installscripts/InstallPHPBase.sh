#!/bin/sh
######################################################################################################
# Description: This script will install the php base
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
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "0" ] )
then
	exit
fi

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
BUILDOSVERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOSVERSION'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSERVER_TYPE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"

apt=""
if ( [ "`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	apt="/usr/sbin/apt-fast"
fi

if ( [ "${apt}" != "" ] )
then
	if ( [ "${BUILDOS}" = "ubuntu" ] )
	then
		if ( [ "${BUILDOSVERSION}" = "20.04" ] || [ "${BUILDOSVERSION}" = "22.04" ] || [ "${BUILDOSVERSION}" = "24.04" ] )
		then
			DEBIAN_FRONTEND=noninteractive /usr/bin/add-apt-repository -y ppa:ondrej/php			#####UBUNTU-PHP-REPO#####
   			if ( [ "${WEBSERVER_TYPE}" = "APACHE" ] )
      			then
	 			DEBIAN_FRONTEND=noninteractive /usr/bin/add-apt-repository -y ppa:ondrej/apache2	#####UBUNTU-PHP-REPO#####
	 		fi
       			if ( [ "${WEBSERVER_TYPE}" = "NGINX" ] )
      			then
	 			DEBIAN_FRONTEND=noninteractive /usr/bin/add-apt-repository -y ppa:ondrej/nginx-mainline	#####UBUNTU-PHP-REPO#####
	 		fi
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y update			#####UBUNTU-PHP-REPO#####
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y upgrade			#####UBUNTU-PHP-REPO#####			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install php${PHP_VERSION}	#####UBUNTU-PHP-REPO#####
   
			php_modules="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PHP" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"
	
			for module in ${php_modules}									#####UBUNTU-PHP-REPO#####
			do												#####UBUNTU-PHP-REPO#####
				DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install php${PHP_VERSION}-${module}	#####UBUNTU-PHP-REPO-SKIP#####
			done												#####UBUNTU-PHP-REPO#####

			/usr/bin/update-alternatives --set php /usr/bin/php${PHP_VERSION}				#####UBUNTU-PHP-REPO#####
	   
		fi
	fi

	if ( [ "${BUILDOS}" = "debian" ] )
	then
 		if ( [ "${BUILDOSVERSION}" = "11" ] || [ "${BUILDOSVERSION}" = "12" ] )
		then	
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y  install lsb-release apt-transport-https ca-certificates #####DEBIAN-PHP-REPO#####
			/usr/bin/wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg						#####DEBIAN-PHP-REPO#####
			/bin/echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list			#####DEBIAN-PHP-REPO#####
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y update							#####DEBIAN-PHP-REPO#####
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y upgrade							#####DEBIAN-PHP-REPO#####
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install php${PHP_VERSION}				#####DEBIAN-PHP-REPO#####
  	
			php_modules="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PHP" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"
	
			for module in ${php_modules}													#####DEBIAN-PHP-REPO#####
			do																#####DEBIAN-PHP-REPO#####
				DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install php${PHP_VERSION}-${module}		#####DEBIAN-PHP-REPO-SKIP#####
			done																#####DEBIAN-PHP-REPO#####
			/usr/bin/update-alternatives --set php /usr/bin/php${PHP_VERSION}								#####DEBIAN-PHP-REPO#####
    		fi
	fi
fi

/usr/bin/find /etc/php -mindepth 1 ! -regex "^/etc/php/${PHP_VERSION}\(/.*\)?" -delete
/bin/touch ${HOME}/runtime/installedsoftware/InstallPHPBase.sh				


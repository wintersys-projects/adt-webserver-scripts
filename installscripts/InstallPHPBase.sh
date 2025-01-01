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
set -x
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "0" ] )
then
	exit
fi

BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
BUILDOSVERSION="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOSVERSION'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSERVER_TYPE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"

apt=""
if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	apt="/usr/sbin/apt-fast"
fi

export DEBIAN_FRONTEND=noninteractive
add_repository_command="/usr/bin/add-apt-repository " 
update_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y update " 
upgrade_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y upgrade " 
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 

if ( [ "${apt}" != "" ] )
then
	if ( [ "${BUILDOS}" = "ubuntu" ] )
	then
		if ( [ "${BUILDOSVERSION}" = "20.04" ] || [ "${BUILDOSVERSION}" = "22.04" ] || [ "${BUILDOSVERSION}" = "24.04" ] )
		then
			${add_repository_command} -y ppa:ondrej/php
      			if ( [ "${WEBSERVER_TYPE}" = "APACHE" ] )
      			then
	 			DEBIAN_FRONTEND=noninteractive /usr/bin/add-apt-repository -y ppa:ondrej/apache2	
	 		fi
       			if ( [ "${WEBSERVER_TYPE}" = "NGINX" ] )
      			then
	 			DEBIAN_FRONTEND=noninteractive /usr/bin/add-apt-repository -y ppa:ondrej/nginx-mainline	
	 		fi
			${update_command}			
			${upgrade_command}						
   			${install_command} php${PHP_VERSION}	
   
			php_modules="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"

 			installable_modules=""
			for module in ${php_modules}									
			do	
   				installable_modules="${installable_modules} php${PHP_VERSION}-${module}"
			done	
			${install_command} ${installable_modules} 
			/usr/bin/update-alternatives --set php /usr/bin/php${PHP_VERSION}				
	   
		fi
	fi

	if ( [ "${BUILDOS}" = "debian" ] )
	then
 		if ( [ "${BUILDOSVERSION}" = "11" ] || [ "${BUILDOSVERSION}" = "12" ] )
		then	
			${install_command} lsb-release apt-transport-https ca-certificates 
			/usr/bin/wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg						
			/bin/echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list			
			${update_command}			
			${upgrade_command}						
   			${install_command} php${PHP_VERSION}					
  	
			php_modules="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PHP" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g'`"
			installable_modules=""
			for module in ${php_modules}													
			do	
				installable_modules="${installable_modules} php${PHP_VERSION}-${module}"
			done	
			${install_command}  ${installable_modules} 		
   			/usr/bin/update-alternatives --set php /usr/bin/php${PHP_VERSION}								
    		fi
	fi
fi

/usr/bin/find /etc/php -mindepth 1 ! -regex "^/etc/php/${PHP_VERSION}\(/.*\)?" -delete
if ( [ "`/usr/bin/php -v | /bin/grep ${PHP_VERSION}`" != "" ] )
then
	/bin/touch ${HOME}/runtime/installedsoftware/InstallPHPBase.sh				
else
	: #Send email
fi

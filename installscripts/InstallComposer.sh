#!/bin/sh
######################################################################################################
# Description: This script will install composer
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


if ( [ "${apt}" != "" ] )
then

	if ( [ "${buildos}" = "ubuntu" ] )
	then
  		${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh cron stop				
		eval ${update_command}			
		eval ${install_command} php-cli unzip	
		cd ~												
		/usr/bin/curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php			
		HASH=`/usr/bin/curl -sS https://composer.github.io/installer.sig`				
		/usr/bin/php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"		
		/usr/bin/php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer		
  		${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh cron start				
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
  		${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh cron stop				
		eval ${update_command}			
		eval ${install_command} php-cli unzip
		cd ~												
		/usr/bin/curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php			
		HASH=`/usr/bin/curl -sS https://composer.github.io/installer.sig`				
		/usr/bin/php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"		
		/usr/bin/php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer		
  		${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh cron start				
	fi
      	/bin/touch ${HOME}/runtime/installedsoftware/InstallComposer.sh				
fi

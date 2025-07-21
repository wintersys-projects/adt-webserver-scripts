#!/bin/sh
###############################################################################################
# Description: This script will install WP cli
# Author: Peter Winter
# Date: 12/01/2017
###############################################################################################
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
################################################################################################
################################################################################################

APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"

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

if ( [ "${APPLICATION}" = "wordpress" ] )
then
	if ( [ "${BUILDOS}" = "ubuntu" ] )
	then
		/usr/bin/wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar 	
		/bin/chmod +x /usr/local/bin/wp
	fi

	if ( [ "${BUILDOS}" = "debian" ] )
	then
		/usr/bin/wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar 	
		/bin/chmod +x /usr/local/bin/wp
	fi

	if ( [ ! -f /usr/local/bin/wp ] )
	then
		${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR WP-CLI" "I believe that wp-cli hasn't installed correctly, please investigate" "ERROR"
	else
		/bin/touch ${HOME}/runtime/installedsoftware/InstallWPCLI.sh
	fi
fi

#!/bin/sh
###########################################################################################################
# Description: Initialise Application Configuration - called during machine build process
# Author : Peter Winter
# Date: 17/05/2017
######################################################################################################
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

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
	exit
fi

${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh moodle_config.php  ${HOME}/runtime/moodle_config.php

if ( [ ! -f ${HOME}/runtime/moodle_config.php] )
then
	${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Unable to obtain the moodle configuration from the datastore during application initiation" "ERROR"
fi

/usr/bin/php -ln ${HOME}/runtime/moodle_config.php

if ( [ "$?" = "0" ] )
then
	/bin/cp ${HOME}/runtime/moodle_config.php /var/www/html/config.php
	/bin/chmod 600 /var/www/html/config.php
	/bin/chown www-data:www-data /var/www/html/config.php

	if ( [ ! -f /var/www/html/config.php ] )
	then
		${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy moodle configuration file to the live location during application initiation" "ERROR"
	else
		/bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
	fi

else
	${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE MALFORMED" "The moodle configuration file appears to be malformed during application initiation" "ERROR"
fi 

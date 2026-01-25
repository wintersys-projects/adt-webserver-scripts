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
######################################################################################################
#set -x

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
	exit
fi

#${HOME}/providerscripts/datastore/configwrapper/PerformSyncConfigDatastore.sh

#if ( [ ! -f /var/lib/adt-config/drupal_settings.php ] )
#then
#	${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"	
#fi

#/bin/cp /var/lib/adt-config/drupal_settings.php /var/www/html/sites/default/settings.php

if ( [ -f /var/www/html/sites/default/settings.php ] )
then
	/bin/rm /var/www/html/sites/default/settings.php
fi

${HOME}/providerscripts/datastore/toolkit/GetFromDatastore.sh "config" "drupal_settings.php" "/var/www/html/sites/default/settings.php"			

/bin/chmod 600 /var/www/html/sites/default/settings.php
/bin/chown www-data:www-data /var/www/html/sites/default/settings.php

/usr/bin/php -ln /var/www/html/sites/default/settings.php

if ( [ "$?" = "0" ] )
then
	/bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
else
	${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"	
fi

#if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
#then#
#	exit
#fi

#${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh drupal_settings.php ${HOME}/runtime

#if ( [ ! -f ${HOME}/runtime/drupal_settings.php ] )
#then#
#	${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Unable to obtain the drupal configuration from the datastore during application initiation" "ERROR"
#fi

#/usr/bin/php -ln ${HOME}/runtime/drupal_settings.php

#if ( [ "$?" = "0" ] )
#then
#	/bin/cp ${HOME}/runtime/drupal_settings.php /var/www/html/sites/default/settings.php
#	/bin/chmod 600 /var/www/html/sites/default/settings.php
#	/bin/chown www-data:www-data /var/www/html/sites/default/settings.php
#
#	if ( [ ! -f /var/www/html/sites/default/settings.php ] )
#	then
#		${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy drupal configuration file to the live location during application initiation" "ERROR"
#	else
#		/bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
#	fi
#
#else
#	${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE MALFORMED" "The drupal configuration file appears to be malformed during application initiation" "ERROR"
#fi 

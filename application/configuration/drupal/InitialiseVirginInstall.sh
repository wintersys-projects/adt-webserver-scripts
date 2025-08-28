#!/bin/sh
#############################################################################
# Description: This script will initialise a virgin copy of drupal
# Author: Peter Winter
# Date: 04/01/2017
###############################################################################
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
#####################################################################################
#####################################################################################
#set -x

#This is how we tell ourselves that this is a drupal application
/bin/echo "DRUPAL" > /var/www/html/dba.dat

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATIONBASELINESOURCECODEREPOSITORY:DRUPAL:social`" = "1" ] )
then
	/bin/echo "SOCIAL_DRUPAL" > /var/www/html/dbt.dat
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATIONBASELINESOURCECODEREPOSITORY:DRUPAL:cms`" = "1" ] )
then
	/bin/echo "CMS_DRUPAL" > /var/www/html/dbt.dat
else
	/bin/echo "DRUPAL" > /var/www/html/dbt.dat
fi

#while ( [ ! -f /var/www/html/sites/default/settings.php ] )
#do#
#	/bin/sleep 2
#done

if ( [ ! -d /var/www/private/default_images ] )
then
	/bin/mkdir -p /var/www/private/default_images
fi

if ( [ ! -d /var/www/tmp ] )
then
	/bin/mkdir -p /var/www/tmp
fi

/bin/chmod 755 /var/www/tmp
/bin/chown www-data:www-data /var/www/tmp

if ( [ -f ${HOME}/runtime/overridehtaccess/htaccess.conf ] )
then
	/bin/cp ${HOME}/runtime/overridehtaccess/htaccess.conf /var/www/html/.htaccess 
	/bin/chmod 444 /var/www/html/.htaccess
	/bin/chown www-data:www-data /var/www/html/.htaccess
fi

#Prepare the configuration file as required by drupal
if ( [ ! -f /var/www/html/sites/default/settings.php ] ||  [ "`/bin/grep 'ADDED BY CONFIG PROCESS' /var/www/html/sites/default/settings.php`" = "" ] )
then
	if ( [ ! -f /var/www/html/sites/default/settings.php ] )
	then
		/bin/cp /var/www/html/sites/default/settings.php.default /var/www/html/sites/default/settings.php
	fi

	if ( [ -f /var/www/html/sites/default/settings.php ] )
	then
		/bin/echo "#====ADDED BY CONFIG PROCESS=====" >> /var/www/html/sites/default/settings.php
		/bin/echo '$config["package_manager.settings"]["executables"]["composer"] = "/usr/local/bin/composer";' >> /var/www/html/sites/default/settings.php 
		/bin/echo '$config["package_manager.settings"]["executables"]["rsync"] = "/usr/bin/rsync";' >> /var/www/html/sites/default/settings.php 
		/bin/echo '$settings["trusted_host_patterns"] = [ ".*" ];' >> /var/www/html/sites/default/settings.php
		/bin/echo '$settings["config_sync_directory"] = "/var/www/html/sites/default";' 
		/bin/echo '$config["system.performance"]["css"]["preprocess"] = FALSE;' >> /var/www/html/sites/default/settings.php
		/bin/echo '$config["system.performance"]["js"]["preprocess"] = FALSE;' >> /var/www/html/sites/default/settings.php
		/bin/echo '$settings['rebuild_access'] = TRUE;' >> /var/www/html/sites/default/settings.php
		/bin/echo '$settings["file_private_path"] = $app_root . "/../private";' >> /var/www/html/sites/default/settings.php
		/bin/echo '$settings["file_temp_path"] = "/tmp";' >> /var/www/html/sites/default/settings.php
		/bin/echo "${0} `/bin/date`: Adjusted the drupal settings: package_manager.settings,file_private_path, trusted_host_patterns, config_sync_directory, system.performance" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
		/bin/cp /var/www/html/sites/default/settings.php ${HOME}/runtime/drupal_settings.php 
	fi
fi


if ( [ -f /var/www/html/example.gitignore ] )
then
	/bin/cp /var/www/html/example.gitignore /var/www/html/.gitignore
fi

/bin/sed -i "/.*$settings\['file_temp_path'\]/c\$settings['file_temp_path'] = '/var/www/tmp';" /var/www/html/sites/default/settings.php

#Remind ourselves what our database prefix is (we have to know this because our database tables will have the same prefix
while ( [ ! -f /var/www/html/dbp.dat ] || [ "`/bin/cat /var/www/html/dbp.dat`" = "" ] )
do
	dbprefix="`/bin/grep "prefix" /var/www/html/sites/default/settings.php | /bin/grep "=>" | /usr/bin/tail -1 | /usr/bin/awk -F"'" '{print $4}'`"

	if ( [ "${dbprefix}" = "" ] )
	then
		dbprefix="`/bin/grep "prefix" /var/www/html/sites/default/settings.php | /bin/grep "=>" | /usr/bin/tail -1 | /usr/bin/awk -F"\\"" '{print $4}'`"
	fi

	/bin/echo ${dbprefix} > /var/www/html/dbp.dat
	/bin/chown www-data:www-data /var/www/html/dbp.dat
	/bin/chmod 600 /var/www/html/dbp.dat
done

#Just for our ease, we remind ourselves of what database engine this webroot is associated with
if ( [ ! -f /var/www/html/dbe.dat ] || [ "`/bin/cat /var/www/html/dbe.dat`" = "" ] )
then
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
	then
		/bin/echo "For your information this application requires Maria DB as its database" > /var/www/html/dbe.dat
	fi

	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
	then
		/bin/echo "For your information this application requires MySQL as its database" > /var/www/html/dbe.dat
	fi

	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
	then
		/bin/echo "For your information this application requires Postgres as its database" > /var/www/html/dbe.dat
	fi

	if ( [ -f /var/www/html/dbe.dat ] )
	then
		/bin/chown www-data:www-data /var/www/html/dbe.dat
		/bin/chmod 600 /var/www/html/dbe.dat
	fi
fi






#!/bin/sh
###########################################################################################################
# Description: Make updated configuration available to other webservers when there is a hit on this machine
# from a application configuration update by an administrator
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

#Make sure configuration file is always has tightened persmissions in case the permissions get inadvertenlty changed. These permissions will be enforced
#evey minute from cron

if ( [ -f /var/www/html/configuration.php ] )
then
	/bin/chmod 600 /var/www/html/configuration.php
	/bin/chown www-data:www-data /var/www/html/configuration.php
fi

installed="0"
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
	if ( [ -d /var/www/html/administrator ] && [ -d /var/www/html/modules ] && [ -d /var/www/html/plugins ] && [ -d /var/www/html/templates ] )
	then
		if ( [ "`/usr/bin/find /var/www/html -type d | /usr/bin/wc -l`" -gt "5" ] && [ "`/usr/bin/find /var/www/html -type f | /usr/bin/wc -l`" -gt "5" ] )
		then
			installed="1"
   		else
     			installed="0"
		fi
	fi
fi

if ( [ "${installed}" = "1" ] )
then
	if ( ( [ -f /var/www/html/configuration.php ] && [ -f ${HOME}/runtime/joomla_configuration.php ] ) && [ "`/usr/bin/diff /var/www/html/configuration.php ${HOME}/runtime/joomla_configuration.php`" != "" ] )
	then
		if ( [ "`/usr/bin/find /var/www/html/configuration.php -cmin -1`" != "" ] )
		then
			if ( [ "`/usr/bin/curl -m 2 --insecure -I 'https://localhost:443/index.php' 2>&1 | /bin/grep 'HTTP' | /bin/grep -w '200\|301\|302\|303'`" != "" ] )
			then
  				if ( [ -f ${HOME}/runtime/joomla_configuration.php ] )
				then
					/bin/mv ${HOME}/runtime/joomla_configuration.php ${HOME}/runtime/joomla_configuration.php-`/usr/bin/date | /bin/sed 's/ //g'`
				fi

				/bin/cp /var/www/html/configuration.php ${HOME}/runtime/joomla_configuration.php
				/usr/bin/php -ln ${HOME}/runtime/joomla_configuration.php
			
   				if ( [ "$?" = "0" ] )
				then
					${HOME}/providerscripts/datastore/dedicated/PutToDatastore.sh "config" "${HOME}/runtime/joomla_configuration.php" "root" "local" "yes"
				fi
			fi
		fi
	elif ( [ "`${HOME}/providerscripts/datastore/config/wrapper/ListFromConfigDatastore.sh joomla_configuration.php`" != "" ] && [ "`/usr/bin/find ${HOME}/runtime/joomla_configuration.php -cmin -1`" = "" ] )
 	then
		if ( [ "`${HOME}/providerscripts/datastore/config/wrapper/AgeOfConfigFile.sh joomla_configuration.php`" -lt "130" ] && [ "`/usr/bin/find /var/www/html/configuration.php -cmin -1`" = "" ] )
		then
            if ( [ -f ${HOME}/runtime/joomla_configuration.php ] )
			then
				/bin/mv ${HOME}/runtime/joomla_configuration.php ${HOME}/runtime/joomla_configuration.php-archive-$$
			fi
		
  			${HOME}/providerscripts/datastore/config/wrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime
			if ( [ -f ${HOME}/runtime/joomla_configuration.php ] )
			then
				/usr/bin/php -ln ${HOME}/runtime/joomla_configuration.php
				if ( [ "$?" = "0" ] )
				then
					if ( [ "`/usr/bin/diff ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php`" = "" ] )
					then
						exit
					fi
					/bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
					/bin/chmod 600 /var/www/html/configuration.php
					/bin/chown www-data:www-data /var/www/html/configuration.php

					if ( [ "`/usr/bin/curl -m 2 --insecure -I 'https://localhost:443/index.php' 2>&1 | /bin/grep 'HTTP' | /bin/grep -w '200\|301\|302\|303'`" = "" ] )
					then
						/bin/mv ${HOME}/runtime/joomla_configuration.php-archive-$$ /var/www/html/configuration.php
					fi
				fi
			else
				${HOME}/providerscripts/email/SendEmail.sh "UNABLE TO OBTAIN APPLICATION CONFIGURATION FROM DATASTORE" "The joomla configuration file could not be obtained from the config datastore" "ERROR"
			fi
   		fi
	fi
fi


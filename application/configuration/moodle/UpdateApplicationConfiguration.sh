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

if ( [ -f /var/www/html/config.php ] )
then
	/bin/chmod 600 /var/www/html/config.php
	/bin/chown www-data:www-data /var/www/html/config.php
fi

installed="0"
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
	if ( [ -f /var/www/html/index.php ] && [ -f /var/www/html/version.php ] && [ -d /var/www/html/userpix ] && [ -d /var/www/html/report ] && [ -d /var/www/html/enrol ] && [ -d /var/www/html/theme ] )
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
	if ( [ "`/usr/bin/find /var/www/html/config.php -cmin -1`" != "" ] )
	if ( ( [ -f /var/www/html/config.php ] && [ -f ${HOME}/runtime/moodle_config.php ] ) && [ "`/usr/bin/diff /var/www/html/config.php ${HOME}/runtime/moodle_config.php`" != "" ] )
	then
		if ( [ "`/usr/bin/curl -m 2 --insecure -I 'https://localhost:443/index.php' 2>&1 | /bin/grep 'HTTP' | /bin/grep -w '200\|301\|302\|303'`" != "" ] )
		then
			if ( [ -f ${HOME}/runtime/moodle_config.php ] )
			then
				/bin/mv ${HOME}/runtime/moodle_config.php ${HOME}/runtime/moodle_config.php-`/usr/bin/date | /bin/sed 's/ //g'`
			fi

			/bin/cp /var/www/html/config.php ${HOME}/runtime/moodle_config.php
			/usr/bin/php -ln ${HOME}/runtime/moodle_config.php
			if ( [ "$?" = "0" ] )
			then
				${HOME}/providerscripts/datastore/dedicated/PutToDatastore.sh "config" "${HOME}/runtime/moodle_config.php" "root" "local" "yes"
			fi
		fi
	elif ( [ "`${HOME}/providerscripts/datastore/config/wrapper/ListFromConfigDatastore.sh moodle_config.php`" != "" ] && [ "`/usr/bin/find ${HOME}/runtime/moodle_config.php -cmin -1`" = "" ] )
 	then
		if ( [ "`${HOME}/providerscripts/datastore/config/wrapper/AgeOfConfigFile.sh moodle_config.php`" -lt "130" ] && [ "`/usr/bin/find /var/www/html/config.php -cmin -1`" = "" ] )
		then
			if ( [ -f ${HOME}/runtime/moodle_config.php ] )
			then
				/bin/mv ${HOME}/runtime/moodle_config.php ${HOME}/runtime/moodle_config.php-archive-$$
			fi
			${HOME}/providerscripts/datastore/config/wrapper/GetFromConfigDatastore.sh moodle_config.php ${HOME}/runtime
			if ( [ -f ${HOME}/runtime/moodle_config.php ] )
			then
				/usr/bin/php -ln ${HOME}/runtime/moodle_config.php
				if ( [ "$?" = "0" ] )
				then
					if ( [ "`/usr/bin/diff ${HOME}/runtime/moodle_config.php /var/www/html/config.php`" = "" ] )
					then
						exit
					fi
					/bin/cp ${HOME}/runtime/moodle_config.php /var/www/html/config.php
					/bin/chmod 600 /var/www/html/config.php
					/bin/chown www-data:www-data /var/www/html/config.php

					if ( [ "`/usr/bin/curl -m 2 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" = "" ] )
					then
						/bin/cp ${HOME}/runtime/moodle_config.php-archive-$$ /var/www/html/config.php
					fi
				fi
			else
				${HOME}/providerscripts/email/SendEmail.sh "UNABLE TO OBTAIN APPLICATION CONFIGURATION FROM DATASTORE" "The moodle configuration file could not be obtained from the config datastore" "ERROR"
			fi
   		fi
	fi
fi



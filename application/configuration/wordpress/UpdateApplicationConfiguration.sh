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

installed="0"
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
	if ( [ -f /var/www/html/wp-login.php ] && [ -d /var/www/html/wp-content ] && [ -f /var/www/html/wp-cron.php ] && [ -d /var/www/html/wp-admin ] && [ -d /var/www/html/wp-includes ] && [ -f /var/www/html/wp-settings.php ] )
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
	if ( [ "`/usr/bin/find /var/www/html/wp-config.php -cmin -1`" != "" ] )
	then
		if ( [ "`/usr/bin/curl -m 2 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" != "" ] )
		then
			if ( [ -f ${HOME}/runtime/wordpress_config.php ] )
			then
				/bin/mv ${HOME}/runtime/wordpress_config.php ${HOME}/runtime/wordpress_config.php.$$
			fi

			/bin/cp /var/www/html/wp-config.php ${HOME}/runtime/wordpress_config.php
			/usr/bin/php -ln ${HOME}/runtime/wordpress_config.php
			if ( [ "$?" = "0" ] )
			then
				${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/wordpress_config.php wordpress_config.php "no"
			fi
		fi
	fi

	/bin/sleep 20

 	if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh wordpress_config.php`" != "" ] )
	then
		if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh wordpress_config.php`" -lt "130" ] && [ "`/usr/bin/find /var/www/html/wp-config.php -cmin -1`" = "" ] )
		then
			if ( [ -f ${HOME}/runtime/wordpress_config.php ] )
			then
				/bin/mv ${HOME}/runtime/wordpress_config.php ${HOME}/runtime/wordpress_config.php.$$
			fi
			${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh wordpress_config.php ${HOME}/runtime/wordpress_config.php
			if ( [ -f ${HOME}/runtime/wordpress_config.php ] )
			then
				/usr/bin/php -ln ${HOME}/runtime/wordpress_config.php
				if ( [ "$?" = "0" ] )
				then
					if ( [ "`/usr/bin/diff ${HOME}/runtime/wordpress_config.php /var/www/html/wp-config.php`" = "" ] )
					then
						exit
					fi
					/bin/cp ${HOME}/runtime/wordpress_config.php /var/www/html/wp-config.php
					/bin/chmod 600 /var/www/html/wp-config.php
					/bin/chown www-data:www-data /var/www/html/wp-config.php

					if ( [ "`/usr/bin/curl -m 2 --insecure -I 'https://localhost:443/index.php' 2>&1 | /bin/grep 'HTTP' | /bin/grep -w '200\|301\|302\|303'`" = "" ] )
					then
						/bin/cp ${HOME}/runtime/wordpress_config.php.$$ /var/www/html/wp-config.php
					fi
				fi
			else
				${HOME}/providerscripts/email/SendEmail.sh "UNABLE TO OBTAIN APPLICATION CONFIGURATION FROM DATASTORE" "The wordpress configuration file could not be obtained from the config datastore" "ERROR"       
			fi
		fi
 	fi
fi

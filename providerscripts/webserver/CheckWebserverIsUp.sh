#!/bin/sh
#########################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Check if the webserver is running and if it isn't try and start it
#########################################################################################
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
#########################################################################################
#########################################################################################
#set -x

export HOME="`/bin/cat /home/homedir.dat`"

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSERVER_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"

# We don't want to be up if we are not secure 
if ( [ ! -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ] || [ ! -f ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ] )
then
	exit
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATIONLANGUAGE:HTML`" = "1" ] )
then
	headfile="index.html"
elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
then
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
	then
		headfile="index.php"
	fi
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
	then
		headfile="index.php"
	fi
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
	then
		headfile="index.php"
	fi
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
	then
		headfile="moodle/index.php"
	fi
fi

php_online="0"

if ( [ "`${HOME}/utilities/processing/RunServiceCommand.sh php${PHP_VERSION} status | /bin/grep 'active' | /bin/grep 'running'`" != "" ] )
then
	php_online="1"
else
	${HOME}/utilities/processing/RunServiceCommand.sh php${PHP_VERSION} restart
 	if ( [ "`${HOME}/utilities/processing/RunServiceCommand.sh php${PHP_VERSION} status | /bin/grep 'active' | /bin/grep 'running'`" != "" ] )
  	then
 		php_online="1"
	fi
fi

if ( [ "${php_online}" = "1" ] )
then

	http_online="0"

	if ( [ "${WEBSERVER_CHOICE}" = "APACHE" ] )
	then
		if ( [ "`${HOME}/utilities/processing/RunServiceCommand.sh apache2 status | /bin/grep 'active' | /bin/grep 'running'`" != "" ] )
 		then
  			http_online="1"
		fi
	elif ( [ "${WEBSERVER_CHOICE}" = "NGINX" ] )
	then
		if ( [ "`${HOME}/utilities/processing/RunServiceCommand.sh nginx status | /bin/grep 'active' | /bin/grep 'running'`" != "" ] )
 		then
  			http_online="1"
		fi
	elif ( [ "${WEBSERVER_CHOICE}" = "LIGHTTPD" ] )
	then
		if ( [ "`${HOME}/utilities/processing/RunServiceCommand.sh lighttpd status | /bin/grep 'active' | /bin/grep 'running'`" != "" ] )
 		then
  			http_online="1"
		fi
	fi

	if ( [ "${http_online}" = "1" ] && [ "`/usr/bin/curl -m 5 --insecure -I "https://localhost:443/${headfile}" 2>&1 | /bin/grep "HTTP" | /bin/grep -vw "200|301|302|303"`" = "" ] )
	then
		http_online="0"
	fi

	if ( [ "${http_online}" = "0" ] && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh INSTALLED_SUCCESSFULLY`" = "INSTALLED_SUCCESSFULLY" ] )
	then
		if ( [ "${WEBSERVER_CHOICE}" = "APACHE" ] )
		then
			${HOME}/utilities/processing/RunServiceCommand.sh apache2 restart 
  
  			if ( [ "`${HOME}/utilities/processing/RunServiceCommand.sh apache2 status | /bin/grep 'active' | /bin/grep 'running'`" = "" ] )
			then
  				if ( [ -f /usr/local/apache2/bin/apachectl ] )
	 			then
					. /etc/apache2/envvars && /usr/local/apache2/bin/apachectl -k restart    
				fi
  			fi
		elif ( [ "${WEBSERVER_CHOICE}" = "NGINX" ] )
		then
			${HOME}/utilities/processing/RunServiceCommand.sh nginx restart 
		elif ( [ "${WEBSERVER_CHOICE}" = "LIGHTTPD" ] )
		then
			${HOME}/utilities/processing/RunServiceCommand.sh lighttpd restart 
		fi
  
  		if ( [ "`/usr/bin/curl -m 5 --insecure -I "https://localhost:443/${headfile}" 2>&1 | /bin/grep "HTTP" | /bin/grep -vw "200|301|302|303"`" != "" ] )
		then
			http_online="1"
		fi
  	fi
	
 	if ( [ "${http_online}" = "1" ] )
	then
		if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh INSTALLED_SUCCESSFULLY`" = "INSTALLED_SUCCESSFULLY" ] && [ -f ${HOME}/runtime/WEBSERVER_READY ] )
		then
			private_ip="`${HOME}/utilities/processing/GetIP.sh`"
			${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${private_ip} beenonline/${private_ip}
		fi
	fi
fi



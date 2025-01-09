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

WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSERVER_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"

# We don't want to be up if we are not secure 
if ( [ ! -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ] || [ ! -f ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ] )
then
	exit
fi

if ( [ "${WEBSERVER_CHOICE}" = "APACHE" ] )
then
	if ( [ "`/usr/bin/ps -ef | /bin/grep php | /bin/grep -v grep`" = "" ] )
	then
    		${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh php${PHP_VERSION}-fpm restart || . /etc/apache2/conf/envvars && /usr/local/apache2/bin/apachectl -k restart 
	fi
	if ( [ "`/usr/bin/ps -ef | /bin/grep apache2 | /bin/grep -v grep`" = "" ] )
	then
		${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh apache2 restart
  
		if ( [ "`/usr/bin/ps -ef | /bin/grep apache2 | /bin/grep -v grep`" = "" ] )
		then
			. /etc/apache2/envvars && /usr/local/apache2/bin/apachectl -k restart    
		fi
		if ( [ "`/usr/bin/ps -ef | /bin/grep apache2 | /bin/grep -v grep`" = "" ] )
		then
			/etc/init.d/apache2 restart
		fi
	fi
fi
if ( [ "${WEBSERVER_CHOICE}" = "NGINX" ] )
then
	/usr/bin/systemctl disable --now apache2
	if ( [ "`/usr/bin/ps -ef | /bin/grep php | /bin/grep -v grep`" = "" ] )
	then
		${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh php${PHP_VERSION}-fpm restart
	fi
	if ( [ "`/usr/bin/ps -ef | /bin/grep nginx | /bin/grep -v grep`" = "" ] )
	then
		${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh nginx restart
	fi
fi

if ( [ "${WEBSERVER_CHOICE}" = "LIGHTTPD" ] )
then
	/usr/bin/systemctl disable --now apache2
	if ( [ "`/usr/bin/ps -ef | /bin/grep php | /bin/grep -v grep`" = "" ] )
	then
		${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh php${PHP_VERSION}-fpm restart
	fi
	if ( [ "`/usr/bin/ps -ef | /bin/grep lighttpd | /bin/grep -v grep`" = "" ] )
	then
 		/usr/bin/killall lighttpd
		/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
	fi
fi

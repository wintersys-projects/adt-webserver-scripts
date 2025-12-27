#!/bin/sh
########################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script restarts the webserver
########################################################################################
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
#######################################################################################
#######################################################################################
#set -x

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

#Prevent ourselves even trying to restart of we are not secure
if ( [ ! -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ] || [ ! -f ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ] )
then
	exit
fi

WEBSERVER_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"
PHP_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"

if ( [ "${WEBSERVER_CHOICE}" = "NGINX" ] )
then
	${HOME}/utilities/processing/RunServiceCommand.sh php${PHP_VERSION}-fpm stop
	${HOME}/utilities/processing/RunServiceCommand.sh php${PHP_VERSION}-fpm start
	${HOME}/utilities/processing/RunServiceCommand.sh "nginx" "stop"
	${HOME}/utilities/processing/RunServiceCommand.sh "nginx" "start"
fi
if ( [ "${WEBSERVER_CHOICE}" = "APACHE" ] )
then
	${HOME}/utilities/processing/RunServiceCommand.sh php${PHP_VERSION}-fpm stop
	${HOME}/utilities/processing/RunServiceCommand.sh php${PHP_VERSION}-fpm start
	${HOME}/utilities/processing/RunServiceCommand.sh "apache2" "stop"
	${HOME}/utilities/processing/RunServiceCommand.sh "apache2" "start"	
	#if ( [ "`/usr/bin/ps -ef | /bin/grep 'apache2 ' | /bin/grep -v grep`" = "" ] )
	#then
#		. /etc/apache2/envvars && /usr/local/apache2/bin/apachectl -k restart
#	fi
fi
if ( [ "${WEBSERVER_CHOICE}" = "LIGHTTPD" ] )
then
	${HOME}/utilities/processing/RunServiceCommand.sh php${PHP_VERSION}-fpm stop
	${HOME}/utilities/processing/RunServiceCommand.sh php${PHP_VERSION}-fpm start
	${HOME}/utilities/processing/RunServiceCommand.sh "lighttpd" "stop"
	${HOME}/utilities/processing/RunServiceCommand.sh "lighttpd" "start"
#	if ( [ "`/usr/bin/ps -ef | /bin/grep lighttpd | /bin/grep -v grep`" = "" ] )
#	then
#		/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
#	fi
fi

HOME="`/bin/cat /home/homedir.dat`"

# If PHP is runing then we know that PHP must be installed so record this in case we missed it during installation
if ( [ "`/bin/ps -ef | /bin/grep php | /bin/grep -v grep`" = "" ] )
then
	/bin/touch ${HOME}/runtime/installedsoftware/InstallApplicationLanguage.sh				
fi

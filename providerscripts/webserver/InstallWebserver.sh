#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will perform a rudimentary configuration of your chosen
# webserver. You are welcome to modify it to your own requirements.
###################################################################################
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
##################################################################################
##################################################################################
#set -x

WEBSERVER_TYPE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

if ( [ "${WEBSERVER_TYPE}" = "NGINX" ] )
then
 	${HOME}/installscripts/InstallNGINX.sh ${BUILDOS}
	if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'NGINX:repo'`" = "1" ] )
	then
		. ${HOME}/providerscripts/webserver/configuration/InstallNginxConfigurationFromRepo.sh
	elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] )
	then
		. ${HOME}/providerscripts/webserver/configuration/InstallNginxConfigurationFromSource.sh
    		while ( [ ! -f ${HOME}/runtime/ESSENTIAL_SOURCEBUILD_SOFTWARE_INSTALLED ] )
  		do
    			/bin/sleep 1
  		done
	fi
	
	#customise by application
	. ${HOME}/providerscripts/webserver/configuration/CustomiseNginxByApplication.sh

 	/bin/touch ${HOME}/runtime/WEBSERVER_INSTALLED
fi

if ( [ "${WEBSERVER_TYPE}" = "APACHE" ] )
then
	#install Apache
	if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:repo'`" = "1" ] )
	then
		. ${HOME}/providerscripts/webserver/configuration/InstallApacheConfigurationFromRepo.sh
	elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'APACHE:source'`" = "1" ] )
	then
	   . ${HOME}/providerscripts/webserver/configuration/InstallApacheConfigurationFromSource.sh 
	fi
	#customise by application
	. ${HOME}/providerscripts/webserver/configuration/CustomiseApacheByApplication.sh
	/bin/touch ${HOME}/runtime/WEBSERVER_INSTALLED
fi
if ( [ "${WEBSERVER_TYPE}" = "LIGHTTPD" ] )
then
	/usr/bin/systemctl disable apache2 && /usr/bin/systemctl stop apache2 2>/dev/null
	
	#install lighthttpd
	 if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:repo'`" = "1" ] )
	then
		. ${HOME}/providerscripts/webserver/configuration/InstallLighttpdConfigurationFromRepo.sh
	elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] )
	then
		. ${HOME}/providerscripts/webserver/configuration/InstallLighttpdConfigurationFromSource.sh 
	fi
	#customise by application
	. ${HOME}/providerscripts/webserver/configuration/CustomiseLighttpdByApplication.sh
	/bin/touch ${HOME}/runtime/WEBSERVER_INSTALLED
fi


	

  


#!/bin/sh
######################################################################################################
# Description: This script will install the apache webserver
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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
set -x

HOME="`/bin/cat /home/homedir.dat`"

if ( [ "${1}" != "" ] )
then
    buildos="${1}"
fi

if ( [ "${buildos}" = "" ] )
then
    BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
else 
    BUILDOS="${buildos}"
fi

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:APACHE`" = "1" ] )
    then
        ${HOME}/providerscripts/webserver/configuration/InstallApacheConfigurationForAuthenticator.sh
    fi
    if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:NGINX`" = "1" ] )
    then
        ${HOME}/providerscripts/webserver/configuration/InstallNginxConfigurationForAuthenticator.sh
    fi
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:APACHE`" = "1" ] )
    then
        ${HOME}/providerscripts/webserver/configuration/InstallApacheConfigurationForAuthenticator.sh
    fi
    if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:NGINX`" = "1" ] )
    then
        ${HOME}/providerscripts/webserver/configuration/InstallNginxConfigurationForAuthenticator.sh
    fi
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:LIGHTTPD`" = "1" ] )
    then
        ${HOME}/providerscripts/webserver/configuration/InstallLighttpdConfigurationForAuthenticator.sh
    fi
    if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh WEBSERVERCHOICE:LIGHTTPD`" = "1" ] )
    then
        ${HOME}/providerscripts/webserver/configuration/InstallLighttpdConfigurationForAuthenticator.sh
    fi
fi

#!/bin/sh
#############################################################################
# Description: This script will check if a webserver is alive and responsive
# on an application basis. You can add your new application to the subdirs and
# have it integrate into the framework.
# Date: 16-11-2016
# Author: Peter Winter
############################################################################
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
############################################################################
############################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:None`" = "1" ] )
then
    /bin/echo "ALIVE"
    exit
fi

DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    SERVER_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    SERVER_NAME="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/* | /usr/bin/head -1`"
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
    . ${HOME}/providerscripts/application/monitoring/joomla/CheckServerAlive.sh
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    . ${HOME}/providerscripts/application/monitoring/wordpress/CheckServerAlive.sh
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    . ${HOME}/providerscripts/application/monitoring/moodle/CheckServerAlive.sh
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then
    . ${HOME}/providerscripts/application/monitoring/drupal/CheckServerAlive.sh
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] )
then
    ${HOME}/providerscripts/utilities/CheckServerAlive.sh
else
    /bin/echo "ALIVE"
fi


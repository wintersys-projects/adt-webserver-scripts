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

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:None`" = "1" ] )
then
	/bin/echo "ALIVE"
	exit
fi

DB_U="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	SERVER_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
	SERVER_NAME="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/* | /usr/bin/head -1`"
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
	. ${HOME}/providerscripts/application/monitoring/joomla/CheckServerAlive.sh
elif ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
	. ${HOME}/providerscripts/application/monitoring/wordpress/CheckServerAlive.sh
elif ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
	. ${HOME}/providerscripts/application/monitoring/moodle/CheckServerAlive.sh
elif ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then
	. ${HOME}/providerscripts/application/monitoring/drupal/CheckServerAlive.sh
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] )
then
	${HOME}/providerscripts/utilities/status/CheckServerAlive.sh
else
	/bin/echo "ALIVE"
fi


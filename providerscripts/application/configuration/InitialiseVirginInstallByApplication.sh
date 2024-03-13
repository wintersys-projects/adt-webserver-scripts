#!/bin/sh
#########################################################################################
# Description: This script will initialise a virgin copy of an application on the server.
# It should be fully primed for use once this script is run, with username, password and
# database set up automatically.
# Date: 16/11/2016
# Author: Peter Winter
######################################################################################
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
####################################################################################
####################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
   exit
fi

#If our credentials are not available, that's no good to us
if ( [ "`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`" = "" ] || [ "`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`" = "" ] || [ "`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`" = "" ] )
then
    /bin/echo "${0} `/bin/date`: Failed to obtain database credentials" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    exit
fi

for applicationdir in `/bin/ls -d ${HOME}/providerscripts/application/configuration/*/`
do
    applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}' | /usr/bin/tr 'a-z' 'A-Z'`"
    if ( [ "`/bin/grep -a "APPLICATIONBASELINESOURCECODEREPOSITORY:${applicationname}" ${HOME}/.ssh/webserver_configuration_settings.dat`" != "" ] )
    then
        . ${applicationdir}InitialiseVirginInstall.sh
    fi
done

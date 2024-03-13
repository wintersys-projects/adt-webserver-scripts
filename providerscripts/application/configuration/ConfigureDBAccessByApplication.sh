#!/bin/sh
#####################################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Most applications have a configuration file in their root directory which contains things
# such as database credentials, database ip address and so on. There are basically some scenarios.
#
# 1) When an application is installed as a virgin, in other words,  the unaltered sourcecode from an
# application provider, for example, joomla or wordpress, then the database credentials are set for this
# application in the script:
#
#        ${HOME}/providerscripts/processing/InitialiseVirginDeployment.sh
#
# also, in this case, it is recorded that the credentials have been set for the new application and this
# script will be ineffective.
#
# 2) When we are installing from a baseline or a backup, then this script is called. There are some conditions
# to be met before it can be run, like is the configuration directory mounted. Once these are met, this script
# runs and sets the database configuration credentials for the application similar to how it is done for the
# virgin install. It does this by calling application specific checks. Because we are not quite sure at what
# point the mounted config directory will be available, we simply run this script from cron every minute.
# In the case when the configuration credentials for the application have been set, this script simply exits.
# As soon as the credentials are successfully set for the application, although this script continues to run
# every minute from cron, it doesn't do anything.
#
# So, basically, 1) the machine is rebooted.
#                2) Every minute after reboot, run this script
#                3) If the credentials haven't been set by either a previous run of this script or the
#                   VirginDeployment script, set the credentials in the applications configuration file
#                   in an application specific way if the credentials have been previously set, simply exit.
#                   We can tell if the credentials have been prviously set by testing for the marker files,
#                   ${HOME}/config/APPLICATION_CONFIGURATION_PREPARED and ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
#                   N.B. We use these different marker files depending upon whether the application requires
#                   that we use a common shared configuration file for all webservers or whether each webserver
#                   instance requires its own configuration file
#######################################################################################################################################
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

SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"

if ( [ "$1" != "" ] )
then
    /bin/echo "Usage: ./ConfigureDBAccessByApplication.sh" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    exit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
    exit
fi

#Retrieve the database server ip address
if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/*`" = "" ] )
then
    exit
fi

DBIP="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/*`"

#If our credentials are not available, that's no good to us
if ( [ "`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`" = "" ] || [ "`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`" = "" ] || [ "`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`" = "" ] )
then
    /bin/echo "${0} `/bin/date`: Failed to obtain database credentials" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
    exit
fi

cd ${HOME}

${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh credentials/shit ${HOME}/shit

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    DBaaS_DBNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSDBNAME'`"
    DBaaS_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSUSERNAME'`"
    DBaaS_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSPASSWORD'`"
    /bin/echo "${DBaaS_DBNAME}" > ${HOME}/shit
    /bin/echo "${DBaaS_PASSWORD}" >> ${HOME}/shit
    /bin/echo "${DBaaS_USERNAME}" >> ${HOME}/shit
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/shit credentials/shit
fi


#We always have our credentials stored in the file shit on the config directory. So, we retrieve our credentials and extract
#the username password and name for our database

k="1"
NAME=""
DATABASE=""
PASSWORD=""

while read line
do
    if ( [ "$k" = "1" ] )
    then
        DATABASE=$line
    fi
    if ( [ "$k" = "2" ] )
    then
        PASSWORD=$line
    fi
    if ( [ "$k" = "3" ] )
    then
        NAME=$line
    fi
    k=$((k+1))
done < ${HOME}/shit

if ( [ "${NAME}" = "" ] || [ "${PASSWORD}" = "" ] || [ "${DATABASE}" = "" ] || [ "${DBIP}" = "" ] )
then
    exit
fi

#So, now, we have all we need. We have our database's username, password and name and we also have the ip address of our database server
#The port number we need to connect to is stored in the file system and was passed over as part of the build process and we can access it as needed

#So, all is set. Run our application specific script. Because it is a sourced file, all that we have set in this script is automatically
#available in the environment of the appilcation specific script, so we don't have to pass any params and so on.
for applicationdir in `/bin/ls -d ${HOME}/providerscripts/application/configuration/*/`
do
    applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}'`"
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:${applicationname}`" = "1" ] )
    then
        . ${applicationdir}ConfigureDBAccess.sh
    fi
done

#!/bin/sh
#####################################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This script will set the application configuration by copying the authoritative configuration
# from the S3 datastore if it is different to the configuration that we hold locally
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

if  ( [ "${1}" = "fromcron" ] )
then
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLED_SUCCESSFULLY"`" = "0" ] )
    then
        exit
    fi
fi

#So, now, we have all we need. We have our database's username, password and name and we also have the ip address of our database server
#The port number we need to connect to is stored in the file system and was passed over as part of the build process and we can access it as needed

#So, all is set. Run our application specific script. Because it is a sourced file, all that we have set in this script is automatically
#available in the environment of the appilcation specific script, so we don't have to pass any params and so on.
for applicationdir in `/bin/ls -d ${HOME}/application/configuration/*/`
do
    applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}'`"
    if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:${applicationname}`" = "1" ] )
    then
        . ${applicationdir}SetApplicationConfiguration.sh
    fi
done

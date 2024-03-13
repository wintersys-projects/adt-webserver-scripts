#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/07/2016
# Description: Update Application Configuration. The configuration file stored in the
# S3 datastore is the authoritative configuration file, changes to the configuration
# files in webroot directories will be overwritten where they differ from what is in 
# the datastore. To update an application configuration, then, you need to update
# the file in ${HOME}/runtime/ and then run this script straight away.
# Be cautious becuase updates being made using this script will be pushed to all your
# webservers. 
#####################################################################################
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

export HOME="`/bin/cat /home/homedir.dat`"

for applicationdir in `/bin/ls -d ${HOME}/providerscripts/application/configuration/*/`
do
    applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}'`"
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:${applicationname}`" = "1" ] )
    then
        . ${applicationdir}ApplicationConfigurationUpdate.sh
    fi
done

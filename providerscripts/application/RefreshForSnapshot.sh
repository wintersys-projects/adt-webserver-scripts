#!/bin/sh
###########################################################################################################
# Description: If you are building from a snapshot this will restore the latest version of your application
# from your datastore because the snapshot you are building off (including the application code) could be
# weeks or even months old so we want our application sourcecode to be up to date
# Author: Peter Winter
# Date: 05/02/2017
###########################################################################################################
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

if ( [  -f ${HOME}/runtime/APPLICATION_WEBROOT_UPDATING ] )
then
        exit
fi

if ( [ -f ${HOME}/runtime/SNAPSHOT_BUILT ] )
then
        if ( [ "`/usr/bin/find ${HOME}/runtime/SNAPSHOT_BUILT -maxdepth 1 -mmin -10 -type f`" != "" ] )
        then
                exit
        fi
fi

if ( [ ! -f ${HOME}/runtime/SNAPSHOT_BUILT ] || [ -f ${HOME}/runtime/APPLICATION_UPDATED_FOR_SNAPSHOT ] )
then
        exit
fi

/bin/touch ${HOME}/runtime/APPLICATION_WEBROOT_UPDATING


${HOME}/providerscripts/application/InstallApplication.sh

${HOME}/providerscripts/utilities/software/UpdateSoftware.sh "SNAPPED"

/bin/touch ${HOME}/runtime/APPLICATION_UPDATED_FOR_SNAPSHOT
/bin/rm ${HOME}/runtime/APPLICATION_WEBROOT_UPDATING




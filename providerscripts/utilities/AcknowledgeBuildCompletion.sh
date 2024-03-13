#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date:    06/07/2016
# Description: The final thing that the infrastructure does before it is ready for
# use is to write the valid DB credentials to a mounted file system which is shared
# to every machine which needs to access the database. Once a machine has access to this
# file, then, we know that they build process is completed. We write a marker file which
# the build client test for and if it finds it then it knows that the build is complete
# and informs the user that they should now be able to navigate to their website.
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
#######################################################################################################
#######################################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:None`" = "1" ] )
then
    /bin/touch ${HOME}/runtime/BUILDCOMPLETED
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "1" ] )
then
    /bin/touch ${HOME}/runtime/BUILDCOMPLETED
fi

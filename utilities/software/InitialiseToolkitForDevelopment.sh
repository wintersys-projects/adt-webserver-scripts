#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: Make a copy of our infrastructure scripts that we can develop against
# and then push to our git provider when needed. 
#######################################################################################
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
########################################################################################
########################################################################################
#set -x

branch="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "GITBRANCH"`"


cd /home/development
/usr/bin/git config --global --add safe.directory /home/development

if ( [ "${1}" = "main" ] )
then
        #Send Email about main branch not being suitable for development
        :
fi

/usr/bin/git branch ${1}
/usr/bin/git fetch --all
/usr/bin/git checkout ${1}
/usr/bin/git pull origin ${1}

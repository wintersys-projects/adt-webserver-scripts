#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: On a reboot, the infrastructure scripts are updated
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

cd ${HOME}

if ( [ -d adt-webserver-scripts ] )
then
	/bin/rm -r adt-webserver-scripts
fi

infrastructure_repository_owner="`${HOME}/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYOWNER'`"
infrastructure_repository_provider="`${HOME}/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPROVIDER'`"
infrastructure_repository_username="`${HOME}/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYUSERNAME'`"
repository_name="adt-webserver-scripts"

${HOME}/providerscripts/git/GitClone.sh "${infrastructure_repository_provider}" "${infrastructure_repository_username}" "${infrastructure_repository_owner}" "${repository_name}"

count="0" 
while ( [ ! -d ${HOME}/${repository_name}/utilities ] && [ "${count}" -le "5" ] )
do
	/bin/sleep 5
	${HOME}/providerscripts/git/GitClone.sh "${infrastructure_repository_provider}" "${infrastructure_repository_username}" "${infrastructure_repository_owner}" "${repository_name}"
	count="`/usr/bin/expr ${count} + 1`"
done

if ( [ -d ${HOME}/${repository_name}/utilities ] )
then
	cd ${HOME}/${repository_name}
	/bin/cp -r * ${HOME}
	cd ..
	/bin/rm -r ${repository_name}
fi

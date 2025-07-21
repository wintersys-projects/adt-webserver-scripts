#!/bin/sh
##################################################################################################################################
# Description: This script will delete the named repository
# Author: Peter Winter
# Date: 11/01/2017
###################################################################################################################################
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
########################################################################################################
#set -x

repository_username="${1}"
repository_password="${2}"
website_name="${3}"
period="${4}"
build_identifier="${5}"
provider_name="${6}"

REPOSITORY_NAME="${website_name}-webroot-sourcecode-${period}-${build_identifier}"
REPOSITORY_PROVIDER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
REPOSITORY_OWNER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"

if ( [ "${provider_name}" = "bitbucket" ] )
then
	/usr/bin/curl -X DELETE --user ${repository_username}:${repository_password} https://api.bitbucket.org/2.0/repositories/${REPOSITORY_OWNER}/${REPOSITORY_NAME}
fi
if ( [ "${provider_name}" = "github" ] )
then
	/usr/bin/curl -X DELETE -u ${repository_username}:${repository_password} https://api.github.com/repos/${REPOSITORY_OWNER}/${REPOSITORY_NAME}
fi
if ( [ "${provider_name}" = "gitlab" ] )
then 
	APPLICATION_REPOSITORY_TOKEN="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYTOKEN'`"
	/usr/bin/curl --request DELETE --header "PRIVATE-TOKEN: ${APPLICATION_REPOSITORY_TOKEN}" https://gitlab.com/api/v3/projects/${REPOSITORY_OWNER}%2F${REPOSITORY_NAME}
fi

#!/bin/sh
###############################################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script clones a git repository
######################################################################################################################################################
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

repository_provider="${1}"
repository_username="${2}"
repository_password="${3}"
repository_ownername="${4}"
repository_name="${5}"

if ( [ "${repository_provider}" = "bitbucket" ] )
then	
	if ( [ "${repository_username}" = "" ] && [ "${repository_password}" = "" ] )
	then
		/usr/bin/git clone https://bitbucket.org/${repository_ownername}/${repository_name}.git
	else
		if ( [ "${repository_password}" = "none" ] )
		then
			/usr/bin/git clone https://${repository_username}@bitbucket.org/${repository_ownername}/${repository_name}.git
		else
			/usr/bin/git clone https://${repository_username}:${repository_password}@bitbucket.org/${repository_ownername}/${repository_name}.git
		fi
	fi
fi
if ( [ "${repository_provider}" = "github" ] )
then
	if ( [ "${repository_username}" = "" ] && [ "${repository_password}" = "" ] )
	then
		/usr/bin/git clone https://github.com/${repository_ownername}/${repository_name}.git
	else
		if ( [ "${repository_password}" = "none" ] )
		then
			/usr/bin/git clone https://${repository_username}@github.com/${repository_ownername}/${repository_name}.git
		else
			/usr/bin/git clone https://${repository_username}:${repository_password}@github.com/${repository_ownername}/${repository_name}.git
		fi
	fi
fi
if ( [ "${repository_provider}" = "gitlab" ] )
then
	if ( [ "${repository_username}" = "" ] && [ "${repository_password}" = "" ] )
	then
		/usr/bin/git clone https://gitlab.com/${repository_ownername}/${repository_name}.git
	else
		if ( [ "${repository_password}" = "none" ] )
		then
			/usr/bin/git clone https://${repository_username}@gitlab.com/${repository_ownername}/${repository_name}.git
		else
			/usr/bin/git clone https://${repository_username}:${repository_password}@gitlab.com/${repository_ownername}/${repository_name}.git
		fi
	fi
fi

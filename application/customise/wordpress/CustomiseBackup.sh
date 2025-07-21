#!/bin/sh
###########################################################################################################
# Description: Customise the backup if you need to specific to wordpress
# Author : Peter Winter
# Date: 17/05/2017
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
#####################################################################################
#####################################################################################

identifier="${1}"

if ( [ "${identifier}" != "" ] )
then
	if ( [ -d ${HOME}/backups/${identifier}  ] )
	then
		if ( [ -f ${HOME}/backups/${identifier}/wp-config.php ] )
		then
			/bin/rm ${HOME}/backups/${identifier}/wp-config.php
		fi
		if ( [ -f ${HOME}/backups/${identifier}/logs ] )
		then
			/bin/rm ${HOME}/backups/${identifier}/logs
		fi
		if ( [ -f ${HOME}/backups/${identifier}/tmp ] )
		then
			/bin/rm ${HOME}/backups/${identifier}/tmp
		fi
		if ( [ -f ${HOME}/backups/${identifier}/cache ] )
		then
			/bin/rm ${HOME}/backups/${identifier}/cache
		fi
	fi
	if ( [ -d ${idenfitier} ] )
	then
		if ( [ -f ${identifier}/wp-config.php ] )
		then
			/bin/rm ${identifier}/wp-config.php
		fi
		if ( [ -f ${identifier}/logs ] )
		then
			/bin/rm ${identifier}/logs
		fi
		if ( [ -f ${identifier}/tmp ] )
		then
			/bin/rm ${identifier}/tmp
		fi
		if ( [ -f ${identifier}/cache ] )
		then
			/bin/rm ${identifier}/cache
		fi
	fi
fi


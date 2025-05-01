#!/bin/sh
###########################################################################################################
# Description: Customise the backup if you need to specific to joomla
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
##########################################################################################
##########################################################################################
#set -x

baseline_name="${1}"

if ( [ "${baseline_name}" != "" ] )
then
	if ( [ -f ${HOME}/backups/${baseline_name}/configuration.php ] )
	then
		/bin/rm ${HOME}/backups/${baseline_name}/configuration.php
  		if ( [ -f ${HOME}/backups/${baseline_name}/logs ] )
    		then
    			/bin/rm -r ${HOME}/backups/${baseline_name}/logs
       		fi
  		if ( [ -f ${HOME}/backups/${baseline_name}/tmp ] )
    		then
    			/bin/rm -r ${HOME}/backups/${baseline_name}/tmp
       		fi
  		if ( [ -f ${HOME}/backups/${baseline_name}/cache ] )
    		then
    			/bin/rm -r ${HOME}/backups/${baseline_name}/cache
       		fi
	fi
fi

if ( [ -f ${HOME}/backuparea//configuration.php ] )
then
	/bin/rm ${HOME}/backuparea//configuration.php
fi




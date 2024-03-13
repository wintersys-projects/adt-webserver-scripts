#!/bin/sh
###########################################################################################
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

if ( [ -d ${HOME}/backups/${baseline_name} ] )
then
    /bin/rm ${HOME}/backups/${baseline_name}/configuration.php
    /bin/rm -r ${HOME}/backups/${baseline_name}/logs/*
    /bin/rm -r ${HOME}/backups/${baseline_name}/tmp/*
    /bin/rm -r ${HOME}/backups/${baseline_name}/cache/*
fi

if ( [ -f /tmp/backup/configuration.php ] )
then
    /bin/rm /tmp/backup/configuration.php
fi




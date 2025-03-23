#!/bin/sh
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
#####################################################################################
#####################################################################################
#set -x

baseline_name="${1}"

if ( [ -d /var/www/moodledata ] )
then
	/bin/mkdir -p /var/www/html/moodledata
	/bin/cp -r /var/www/moodledata/* /var/www/html/moodledata
fi

if ( [ -f ${HOME}/backups/${baseline_name}/moodle/config.php ] )
then
	/bin/rm ${HOME}/backups/${baseline_name}/moodle/config.php
fi

if ( [ -f /tmp/backup/moodle/config.php ] )
then
	/bin/rm /tmp/backup/moodle/config.php
fi



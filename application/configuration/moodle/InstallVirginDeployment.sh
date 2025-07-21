#!/bin/sh
#############################################################################
# Description: This script will obtain and extract the sourcecode for moodle into 
# the webroot directory# Author: Peter Winter
# Date: 04/01/2017
#################################################################################
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
####################################################################################
####################################################################################
#set -x

/bin/mkdir /var/www/html/moodle
/usr/bin/git clone git://git.moodle.org/moodle.git /var/www/html/moodle              
cd /var/www/html/moodle
version="`/usr/bin/git branch -a | /bin/grep STABLE | /usr/bin/tail -n -1 | /usr/bin/awk -F'/' '{print $NF}'`"
/usr/bin/git branch --track ${version} origin/${version}     
/usr/bin/git checkout ${version}
cd ${HOME}
/bin/mv /var/www/html/moodle/* /var/www/html
/bin/rm -r /var/www/html/moodle




#!/bin/sh
######################################################################################
# Description: This will verify which application type will install
# Date: 16-11-2016
# Author: Peter Winter
########################################################################################
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
################################################################################
################################################################################
#set -x

if ( [ -f /var/www/html/moodle/index.php ] && [ -f /var/www/html/moodle/version.php ] && [ -d /var/www/html/moodle/userpix ] && [ -d /var/www/html/moodle/userpix ] && [ -d /var/www/html/moodle/report ] && [ -d /var/www/html/moodle/enrol ] && [ -d /var/www/html/moodle/theme ] ) 
then
    installed="1"
fi

#!/bin/sh
#################################################################################
# Description: This script will interrogate the filesystem of the application to
# determine which application type it is
# Author: Peter Winter
# Date: 10/01/2017
##################################################################################
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
#################################################################################
#################################################################################
#set -x
if ( [ -d /var/www/html/moodle/admin ] && [ -d /var/www/html/moodle/portfolio ] &&  [ -d /var/www/html/moodle/repository ] )
then
    ${HOME}/providerscripts/utilities/StoreConfigValue.sh "APPLICATION" "moodle"
fi

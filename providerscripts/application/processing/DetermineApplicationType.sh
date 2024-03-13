#!/bin/sh
#######################################################################################
# Description: This script will discern which Application you are running, if any. As
# you add new Application types, you can add them to this script. You need to find
# something which is unique to the Application and ever present to test which
# Application it is. It should be fairly obvious from the examples.
# Date: 16-11-2016
# Author : Peter Winter
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

for applicationdir in `/bin/ls -d ${HOME}/providerscripts/application/processing/*/`
do
    . ${applicationdir}DetermineApplicationType.sh
done

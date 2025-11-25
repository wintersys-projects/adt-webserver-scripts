#!/bin/sh
####################################################################################
# Description: When you have a baselined application that you want to prepare for temporal backup
# deployment if you want your assets to be mounted from S3, you will need to prepare them using this
# script
# Author: Peter Winter
# Date :  9/4/2023
###################################################################################
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

/bin/touch ${HOME}/runtime/PREPARE_MOUNTS 
${HOME}/providerscripts/datastore/assets/SetupAssetsStore.sh
/bin/rm ${HOME}/runtime/PREPARE_MOUNTS 

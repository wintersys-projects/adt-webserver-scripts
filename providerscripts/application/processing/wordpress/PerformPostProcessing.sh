#!/bin/sh
#####################################################################################
# Description: If your application requires any post processing to be performed, then,
# this is the place to put it. Post processing is considered to be any processing which
# is required after the application is considered installed. This is the post processing
# for a joomla install. If you examine the code, you will find that this script is called
# from the build client over ssh once it considers that the application has been fully installed.
#   ***********IMPORTANT*****************
#   These post processing scipts are not run using sudo as is normally the case, this is because
#   of issues with stdin and so on. So if a command requires privilege then sudo must be used
#   on a command by command basis. This is true for all PerformPostProcessing Scripts
#   ***********IMPORTANT*****************
# Author: Peter Winter
# Date: 04/01/2017
###############################################################################################
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

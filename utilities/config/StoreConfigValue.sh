#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: Store a config value
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
########################################################################################
########################################################################################
#set -x

export HOME="`/bin/cat /home/homedir.dat`"

if ( [ ! -f ${HOME}/runtime/webserver_configuration_settings.dat ] )
then
	exit
fi

/bin/sed -i '/:/!d' ${HOME}/runtime/webserver_configuration_settings.dat

if ( [ "${1}" != "" ] && [ "${2}" != "" ] )
then
	/bin/sed -i "/.*${1}:/d" ${HOME}/runtime/webserver_configuration_settings.dat
	/bin/sed -i "\$ a\ ${1}:${2}" ${HOME}/runtime/webserver_configuration_settings.dat 
	/bin/sed -i "s/^ //g" ${HOME}/runtime/webserver_configuration_settings.dat 
elif ( [ "${1}" != "" ] && [ "${2}" = "" ] )
then
	/bin/sed -i "/.*${1}$/d" ${HOME}/runtime/webserver_configuration_settings.dat
	/bin/sed -i "\$ a\ ${1}" ${HOME}/runtime/webserver_configuration_settings.dat 
	/bin/sed -i "s/^ //g" ${HOME}/runtime/webserver_configuration_settings.dat 
fi

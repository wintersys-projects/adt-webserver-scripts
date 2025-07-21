#!/bin/sh 
###############################################################################################
# Description: This will install Goofys
# Author: Peter Winter
# Date: 12/01/2017
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
################################################################################################
################################################################################################

if ( [ "${1}" != "" ] )
then
	buildos="${1}"
fi

if ( [ "${buildos}" = "" ] )
then
	BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
else 
	BUILDOS="${buildos}"
fi

cwd="`/usr/bin/pwd`"

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
	if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:binary'`" = "1" ] )
	then
		/usr/bin/wget https://github.com/kahing/goofys/releases/latest/download/goofys -P /usr/bin	
		/bin/chmod 755 /usr/bin/goofys									
	fi
	if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:source'`" = "1" ] )
	then
		${HOME}/installscripts/InstallGo.sh ${BUILDOS}
		cd /opt
		/usr/bin/git clone https://github.com/kahing/goofys.git
		cd goofys
		/usr/bin/git submodule init
		/usr/bin/git submodule update
		/usr/bin/go install
		/bin/cp ${HOME}/go/bin/goofys /usr/bin
		cd ..
		/bin/rm -r goofys
		cd ${cwd}
	fi
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
	if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:binary'`" = "1" ] )
	then
		/usr/bin/wget https://github.com/kahing/goofys/releases/latest/download/goofys -P /usr/bin      
		/bin/chmod 755 /usr/bin/goofys                                                                  												
	fi
	if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:source'`" = "1" ] )
	then
		${HOME}/installscripts/InstallGo.sh ${BUILDOS}
		cd /opt
		/usr/bin/git clone https://github.com/kahing/goofys.git
		cd goofys
		/usr/bin/git submodule init
		/usr/bin/git submodule update
		/usr/bin/go install
		/bin/cp ${HOME}/go/bin/goofys /usr/bin
		cd ..
		/bin/rm -r goofys
		cd ${cwd}
	fi
fi	

if ( [ ! -f /usr/bin/goofys ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR GOOFYS" "I believe that goofys hasn't installed correctly, please investigate" "ERROR"
else
	/bin/touch ${HOME}/runtime/installedsoftware/InstallGoofyFS.sh	
fi


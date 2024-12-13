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

apt=""
if ( [ "`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	apt="/usr/sbin/apt-fast"
fi

if ( [ "${apt}" != "" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:binary'`" = "1" ] )
		then
			/usr/bin/wget https://github.com/kahing/goofys/releases/latest/download/goofys -P /usr/bin	#####UBUNTU-GOOFYS-BINARY#####
			/bin/chmod 755 /usr/bin/goofys									#####UBUNTU-GOOFYS-BINARY#####
		elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:source'`" = "1" ] )
		then
			if ( [ -d /root/scratch ] )                                             #####UBUNTU-GOOFYS-SOURCE#####
			then                                                                    #####UBUNTU-GOOFYS-SOURCE#####
        			/bin/rm -r /root/scratch                                        #####UBUNTU-GOOFYS-SOURCE#####
			else                                                                    #####UBUNTU-GOOFYS-SOURCE#####
        			/bin/mkdir /root/scratch                                        #####UBUNTU-GOOFYS-SOURCE#####
			fi                                                                      #####UBUNTU-GOOFYS-SOURCE#####

			cwd="`/usr/bin/pwd`"                                                    #####UBUNTU-GOOFYS-SOURCE#####
        		DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install make    #####UBUNTU-GOOFYS-SOURCE#####
        		/usr/bin/git clone https://github.com/kahing/goofys.git /root/scratch                                           #####UBUNTU-GOOFYS-SOURCE#####
        		cd /root/scratch                                                                                        #####UBUNTU-GOOFYS-SOURCE#####
        		/usr/bin/make install                                                                                   #####UBUNTU-GOOFYS-SOURCE#####

        		if ( [ -f ${HOME}/go/bin/goofys ] )                                                                       #####UBUNTU-GOOFYS-SOURCE#####
        		then                                                                                                    #####UBUNTU-GOOFYS-SOURCE#####
                		/bin/mv ${HOME}/go/bin/goofys /usr/bin                                                                    #####UBUNTU-GOOFYS-SOURCE-SKIP#####
                		/bin/chmod 755 /usr/bin/goofys                                                                  #####UBUNTU-GOOFYS-SOURCE#####
        		fi                                                                                                      #####UBUNTU-GOOFYS-SOURCE#####

        		if ( [ -d /root/scratch ] )                                                                             #####UBUNTU-GOOFYS-SOURCE#####
        		then                                                                                                    #####UBUNTU-GOOFYS-SOURCE#####
                		/bin/rm -r /root/scratch                                                                        #####UBUNTU-GOOFYS-SOURCE#####
        		fi                                                                                                      #####UBUNTU-GOOFYS-SOURCE#####
			cd ${cwd}
		fi
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
        	if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:binary'`" = "1" ] )
        	then
                	/usr/bin/wget https://github.com/kahing/goofys/releases/latest/download/goofys -P /usr/bin      #####DEBIAN-GOOFYS-BINARY#####
                	/bin/chmod 755 /usr/bin/goofys                                                                  #####DEBIAN-GOOFYS-BINARY#####
        	elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:goof:source'`" = "1" ] )
        	then
                	if ( [ -d /root/scratch ] )                                             #####DEBIAN-GOOFYS-SOURCE#####
                	then                                                                    #####DEBIAN-GOOFYS-SOURCE#####
                        	/bin/rm -r /root/scratch                                        #####DEBIAN-GOOFYS-SOURCE#####
                	else                                                                    #####DEBIAN-GOOFYS-SOURCE#####
                        	/bin/mkdir /root/scratch                                        #####DEBIAN-GOOFYS-SOURCE#####
                	fi                                                                      #####DEBIAN-GOOFYS-SOURCE#####

                	cwd="`/usr/bin/pwd`"                                                    #####DEBIAN-GOOFYS-SOURCE#####
                	DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install make    #####DEBIAN-GOOFYS-SOURCE#####
                	/usr/bin/git clone https://github.com/kahing/goofys.git /root/scratch                                           #####DEBIAN-GOOFYS-SOURCE#####
                	cd /root/scratch                                                                                        #####DEBIAN-GOOFYS-SOURCE#####
                	/usr/bin/make install                                                                                   #####DEBIAN-GOOFYS-SOURCE#####

                	if ( [ -f ${HOME}/go/bin/goofys ] )                                                                       #####DEBIAN-GOOFYS-SOURCE#####
                	then                                                                                                    #####DEBIAN-GOOFYS-SOURCE#####
                        	/bin/mv ${HOME}/go/bin/goofys /usr/bin                                                            #####DEBIAN-GOOFYS-SOURCE-SKIP#####
                        	/bin/chmod 755 /usr/bin/goofys                                                                  #####DEBIAN-GOOFYS-SOURCE#####
                	fi                                                                                                      #####DEBIAN-GOOFYS-SOURCE#####

                	if ( [ -d /root/scratch ] )                                                                             #####DEBIAN-GOOFYS-SOURCE#####
                	then                                                                                                    #####DEBIAN-GOOFYS-SOURCE#####
                        	/bin/rm -r /root/scratch                                                                        #####DEBIAN-GOOFYS-SOURCE#####
                	fi                                                                                                      #####DEBIAN-GOOFYS-SOURCE#####
                	cd ${cwd}												#####DEBIAN-GOOFYS-SOURCE#####
		fi
   		
        fi
	/bin/touch ${HOME}/runtime/installedsoftware/InstallGoofyFS.sh			
fi

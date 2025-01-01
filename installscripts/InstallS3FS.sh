#!/bin/sh
######################################################################################################
# Description: This script will install the s3fs system
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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
#######################################################################################################
#######################################################################################################

if ( [ "${1}" != "" ] )
then
	buildos="${1}"
fi

apt=""
if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	apt="/usr/sbin/apt-fast"
fi

export DEBIAN_FRONTEND=noninteractive
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install "

if ( [ "${apt}" != "" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		if ( [ ! -f /usr/bin/s3fs ] )
		then
			if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:repo'`" = "1" ] )
			then
				${install_command} s3fs	
			elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:source'`" = "1" ] )
			then
                        	${install_command} build-essential git libfuse-dev libcurl4-openssl-dev libxml2-dev automake libtool pkg-config libssl-dev   

                                if ( [ -d /root/scratch ] )					
                                then								
                                        /bin/rm -r /root/scratch/*				
                                else								
                                        /bin/mkdir /root/scratch				
                                fi								
                                cwd="`/usr/bin/pwd`"						
                                cd /root/scratch						
                                /usr/bin/git clone https://github.com/s3fs-fuse/s3fs-fuse                                                                                                             
                                cd s3fs-fuse/                                                   
                                ./autogen.sh                                                    
                                ./configure --prefix=/usr --with-openssl                        
                                /usr/bin/make                                                   
                                /usr/bin/make install						
                                cd ${cwd}							
                                /bin/rm -r /root/scratch					
			fi
		fi
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
		if ( [ ! -f /usr/bin/s3fs ] )
		then
			if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:repo'`" = "1" ] )
			then
				${${install_command} } s3fs		
			elif ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:source'`" = "1" ] )
			then
                        	${install_command} build-essential git libfuse-dev libcurl4-openssl-dev libxml2-dev automake libtool pkg-config libssl-dev    

                                if ( [ -d /root/scratch ] )					
                                then								
                                        /bin/rm -r /root/scratch/*			
                                else								
                                        /bin/mkdir /root/scratch				
                                fi								
                                cwd="`/usr/bin/pwd`"						
                                cd /root/scratch						
                                /usr/bin/git clone https://github.com/s3fs-fuse/s3fs-fuse                                                                                                              
                                cd s3fs-fuse/                                                 
                                ./autogen.sh                                                    
                                ./configure --prefix=/usr --with-openssl                        
                                /usr/bin/make                                                   
                                /usr/bin/make install						
                                cd ${cwd}							
                                /bin/rm -r /root/scratch					
			fi
		fi
	fi
      	/bin/touch ${HOME}/runtime/installedsoftware/InstallS3FS.sh				
fi

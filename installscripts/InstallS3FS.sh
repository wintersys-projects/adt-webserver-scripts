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
		if ( [ ! -f /usr/bin/s3fs ] )
		then
			if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:repo'`" = "1" ] )
			then
				DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install s3fs	#####UBUNTU-S3FS-REPO#####
			elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:source'`" = "1" ] )
			then
                        	DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install build-essential git libfuse-dev libcurl4-openssl-dev libxml2-dev automake libtool       #####UBUNTU-S3FS-SOURCE#####
                                DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install pkg-config libssl-dev                                                                   #####UBUNTU-S3FS-SOURCE#####

                                if ( [ -d /root/scratch ] )					#####UBUNTU-S3FS-SOURCE#####
                                then								#####UBUNTU-S3FS-SOURCE#####
                                        /bin/rm -r /root/scratch/*				#####UBUNTU-S3FS-SOURCE#####
                                else								#####UBUNTU-S3FS-SOURCE#####
                                        /bin/mkdir /root/scratch				#####UBUNTU-S3FS-SOURCE#####
                                fi								#####UBUNTU-S3FS-SOURCE#####
                                cwd="`/usr/bin/pwd`"						#####UBUNTU-S3FS-SOURCE#####
                                cd /root/scratch						#####UBUNTU-S3FS-SOURCE#####
                                /usr/bin/git clone https://github.com/s3fs-fuse/s3fs-fuse       #####UBUNTU-S3FS-SOURCE#####                                                                                                        
                                cd s3fs-fuse/                                                   #####UBUNTU-S3FS-SOURCE#####
                                ./autogen.sh                                                    #####UBUNTU-S3FS-SOURCE#####
                                ./configure --prefix=/usr --with-openssl                        #####UBUNTU-S3FS-SOURCE#####
                                /usr/bin/make                                                   #####UBUNTU-S3FS-SOURCE#####
                                /usr/bin/make install						#####UBUNTU-S3FS-SOURCE#####
                                cd ${cwd}							#####UBUNTU-S3FS-SOURCE-SKIP#####
                                /bin/rm -r /root/scratch					#####UBUNTU-S3FS-SOURCE#####
			fi
		fi
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
		if ( [ ! -f /usr/bin/s3fs ] )
		then
			if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:repo'`" = "1" ] )
			then
				DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install s3fs		#####DEBIAN-S3FS-REPO#####
			elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTOREMOUNTTOOL:s3fs:source'`" = "1" ] )
			then
                        	DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install build-essential git libfuse-dev libcurl4-openssl-dev libxml2-dev automake libtool       #####DEBIAN-S3FS-SOURCE#####
                                DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install pkg-config libssl-dev                                                                   #####DEBIAN-S3FS-SOURCE#####

                                if ( [ -d /root/scratch ] )					#####DEBIAN-S3FS-SOURCE#####
                                then								#####DEBIAN-S3FS-SOURCE#####
                                        /bin/rm -r /root/scratch/*				#####DEBIAN-S3FS-SOURCE#####
                                else								#####DEBIAN-S3FS-SOURCE#####
                                        /bin/mkdir /root/scratch				#####DEBIAN-S3FS-SOURCE#####
                                fi								#####DEBIAN-S3FS-SOURCE#####
                                cwd="`/usr/bin/pwd`"						#####DEBIAN-S3FS-SOURCE#####
                                cd /root/scratch						#####DEBIAN-S3FS-SOURCE#####
                                /usr/bin/git clone https://github.com/s3fs-fuse/s3fs-fuse       #####DEBIAN-S3FS-SOURCE#####                                                                                                        
                                cd s3fs-fuse/                                                   #####DEBIAN-S3FS-SOURCE#####
                                ./autogen.sh                                                    #####DEBIAN-S3FS-SOURCE#####
                                ./configure --prefix=/usr --with-openssl                        #####DEBIAN-S3FS-SOURCE#####
                                /usr/bin/make                                                   #####DEBIAN-S3FS-SOURCE#####
                                /usr/bin/make install						#####DEBIAN-S3FS-SOURCE#####
                                cd ${cwd}							#####DEBIAN-S3FS-SOURCE-SKIP#####
                                /bin/rm -r /root/scratch					#####DEBIAN-S3FS-SOURCE#####
			fi
		fi
	fi
      	/bin/touch ${HOME}/runtime/installedsoftware/InstallS3FS.sh				
fi

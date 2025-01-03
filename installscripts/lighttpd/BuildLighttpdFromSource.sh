#!/bin/sh
######################################################################################################
# Description: This will install and compile lighttpd from source code. This has the advantage that its
# the latest version of lighttpd will be used when sometimes repositories can use more dated versions.
# You also have control over what features of apache are intalled by varying the options which are 
# used during the compilation. You can configure custom options by modifying the file:
#
#  ${BUILD_HOME}/builddescriptors/buildstylesscp.dat
#
# on the your build machine. 
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
#set -x

export HOME=`/bin/cat /home/homedir.dat`
BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

#Install needed libraries
if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
then
	apt=""
	if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
	then
		apt="/usr/bin/apt-get"
	elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
	then
		apt="/usr/sbin/apt-fast"
	fi
	export DEBIAN_FRONTEND=noninteractive
 	update_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y update " 
	install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 
	${update_command} 
        ${install_command} autoconf automake libtool m4 pkg-config build-essential libpcre3-dev libpcre2-dev zlib1g zlib1g-dev  libssl-dev
        if ( [ "$?" = "0" ] )
        then
                /bin/touch ${HOME}/runtime/ESSENTIAL_SOURCEBUILD_SOFTWARE_INSTALLED
        fi
fi

cwd="`/usr/bin/pwd`"

cd /usr/local/src/

minor_version="`/usr/bin/curl -L https://api.github.com/repos/lighttpd/lighttpd1.4/tags | /usr/bin/jq -r '.[] | .name' | /usr/bin/awk -F'-' '{print $2}' | /usr/bin/head -1`"
major_version="`/bin/echo ${minor_version} | /usr/bin/awk -F'.' -v OFS="." '{print $1,$2}'`"
/usr/bin/wget https://github.com/lighttpd/lighttpd${major_version}/archive/refs/tags/lighttpd-${minor_version}.tar.gz
/bin/tar xvfz lighttpd-${minor_version}.tar.gz

cd lighttpd${major_version}-lighttpd-${minor_version}

/bin/sed -i 's/trap/#trap/g' ./autogen.sh #was getting a "bad trap error from this script
./autogen.sh

#Get any lise of custom mulues that we are installing and compile with the custom modules if there are any or compile a default build if not
lighttpd_modules="`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/source//g'`"    #####SOURCE_BUILD_VAR#####

if ( [ "${lighttpd_modules}" != "" ] )
then
        with_modules=""
        for module in ${lighttpd_modules}
        do
                with_modules=${with_modules}" --with-${module} "
        done
        ./configure -C --prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib ${with_modules}
else
        ./configure -C --prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib -with-openssl --disable-ipv6 
fi

/usr/bin/make
/usr/bin/make install 

/bin/mkdir /etc/lighttpd
/bin/mkdir /var/log/lighttpd
/bin/chown www-data:www-data /var/log/lighttpd

/bin/cp /usr/local/src/lighttpd${major_version}-lighttpd-${minor_version}/doc/systemd/lighttpd.service /usr/lib/systemd/system
/usr/bin/systemctl daemon-reload
/usr/bin/systemctl enable lighttpd

#/bin/mv ${HOME}/light* /usr/share/lighttpd

cd ${cwd}

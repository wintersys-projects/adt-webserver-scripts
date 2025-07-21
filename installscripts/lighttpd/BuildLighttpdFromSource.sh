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
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

cwd="`/usr/bin/pwd`"

cd /usr/local/src/

minor_version="`/usr/bin/curl -L https://api.github.com/repos/lighttpd/lighttpd1.4/tags | /usr/bin/jq -r '.[] | .name' | /usr/bin/awk -F'-' '{print $2}' | /usr/bin/head -1`"
major_version="`/bin/echo ${minor_version} | /usr/bin/awk -F'.' -v OFS="." '{print $1,$2}'`"
/usr/bin/wget https://github.com/lighttpd/lighttpd${major_version}/archive/refs/tags/lighttpd-${minor_version}.tar.gz
/bin/tar xvfz lighttpd-${minor_version}.tar.gz

cd lighttpd${major_version}-lighttpd-${minor_version}

/bin/sed -i 's/trap/#trap/g' ./autogen.sh #was getting a "bad trap error from this script
./autogen.sh

lighttpd_modules="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:modules-list" "stripped" | /bin/sed 's/|.*//g' | /bin/sed 's/:/ /g' | /bin/sed 's/modules-list//'`"

if ( [ "${lighttpd_modules}" != "" ] )
then
    if ( [ ! -d /etc/lighttpd ] )
    then
        /bin/mkdir /etc/lighttpd
    fi

    /bin/echo "server.modules = (" > /etc/lighttpd/modules.conf

    for module in ${lighttpd_modules}
    do
        /bin/echo '"'${module}'",' >> /etc/lighttpd/modules.conf
    done

    /usr/bin/truncate -s -2 /etc/lighttpd/modules.conf
    /bin/echo "" >> /etc/lighttpd/modules.conf
    /bin/echo ")" >> /etc/lighttpd/modules.conf
fi

#Get any lise of custom mulues that we are installing and compile with the custom modules if there are any or compile a default build if not
static_lighttpd_modules="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "LIGHTTPD:static-modules-list" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/static-modules-list//g' | /bin/sed 's/^ //'`"    

if ( [ "${static_lighttpd_modules}" != "" ] )
then
    with_modules=""
    for module in ${static_lighttpd_modules}
    do
        with_modules=${with_modules}" --with-${module} "
    done
    ./configure -C --prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib --disable-ipv6  ${with_modules}
else
    ./configure -C --prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib --with-zlib --with-libxml --with-openssl --disable-ipv6 
fi

/usr/bin/make
/usr/bin/make install 

if ( [ ! -d  /etc/lighttpd  ] )
then
    /bin/mkdir /etc/lighttpd        
fi

if ( [ ! -d  /var/log/lighttpd  ] )
then
    /bin/mkdir /var/log/lighttpd
fi

/bin/chown www-data:www-data /var/log/lighttpd

if ( [ -f /usr/local/src/lighttpd${major_version}-lighttpd-${minor_version}/doc/systemd/lighttpd.service ] )
then
    /bin/cp /usr/local/src/lighttpd${major_version}-lighttpd-${minor_version}/doc/systemd/lighttpd.service /usr/lib/systemd/system
fi
/usr/bin/systemctl daemon-reload
/usr/bin/systemctl enable lighttpd

cd ${cwd}

/bin/touch /etc/lighttpd/BUILT_FROM_SOURCE	
/bin/touch ${HOME}/runtime/installedsoftware/InstallLighttpd.sh				



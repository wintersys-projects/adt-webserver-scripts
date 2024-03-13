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
BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"

#Install needed libraries
if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
then
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -qq -y autoconf automake libtool m4 pkg-config 
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -qq -y bzip2 libgeoip-dev gnutls-bin gnutls-dev libmaxminddb-dev libxml2 libmariadb-dev libpq-dev zlib1g-dev libssl-dev libpcre3-dev
fi

#Get the latest version of lighttpd
release_series="1"
version_name="`/usr/bin/wget -O- - https://github.com/lighttpd | /bin/grep -o lighttpd[${release_series}].[0-9][0-9] | /bin/grep lighttpd | /usr/bin/head -1`"
if ( [ "${version_name}" = "" ] )
then
    version_name="`/usr/bin/wget -O- - https://github.com/lighttpd | /bin/grep -o lighttpd[${release_series}].[0-9] | /bin/grep lighttpd | /usr/bin/head -1`"
fi

/usr/bin/git clone https://github.com/lighttpd/${version_name}.git
cd ${version_name}

./autogen.sh

#Get any lise of custom mulues that we are installing and compile with the custom modules if there are any or compile a default build if not
modules="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "LIGHTTPD" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/source//g'`"

if ( [ "${modules}" != "" ] )
then
    with_modules=""
    for module in ${modules}
    do
        with_modules=${with_modules}" --with-${module} "
    done
    ./configure -C --prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib ${with_modules}
else
    ./configure -C --prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib --with-geoip --with-gnutls --with-maxminddb --with-pgsql --with-mysql --with-openssl --with-pcre --with-rewrite --with-redirect --with-ssl --with-fastcgi --with-fastcgi-php
fi
/usr/bin/make
/usr/bin/make install 

/bin/mkdir /etc/lighttpd
/bin/mkdir /var/log/lighttpd
/bin/chown www-data:www-data /var/log/lighttpd

/bin/mv ${HOME}/light* /usr/share/lighttpd

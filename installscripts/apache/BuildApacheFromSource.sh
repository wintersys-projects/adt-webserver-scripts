#!/bin/sh
######################################################################################################
# Description: This will install and compile apache from source code. This has the advantage that its
# the latest version of apache will be used when sometimes repositories can use more dated versions.
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

if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
then
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get  -o DPkg::Lock::Timeout=-1  -qq -y  install pandoc build-essential libssl-dev libexpat-dev libpcre3-dev libapr1-dev libaprutil1-dev libnghttp2-dev
fi

/bin/mkdir /usr/local/apache2
/bin/mkdir /etc/apache2

cd /usr/local/src/

#Optain the latest version of apache sourcecode using the checksum to insure its integrity and extract it into the /usr/local/src directory
apache_latest_version="`/usr/bin/curl https://httpd.apache.org/download.cgi | /usr/bin/pandoc -f html -t plain | grep -o "^Apache HTTP Server.*(" | /usr/bin/tr -dc '[0-9].'`"
apache_download_link="https://archive.apache.org/dist/httpd/httpd-${apache_latest_version}.tar.bz2"
apache_download_checksum="https://archive.apache.org/dist/httpd/httpd-${apache_latest_version}.tar.bz2.sha256"
/usr/bin/wget ${apache_download_link}
/usr/bin/wget ${apache_download_checksum}

if ( [ "`/usr/bin/sha256sum --check ./httpd-${apache_latest_version}.tar.bz2.sha256 | /bin/grep "OK"`" = "" ] )
then
    exit
else
    /bin/tar -xvjf ./httpd-${apache_latest_version}.tar.bz2
fi

/bin/rm *tar*

cd /usr/local/src/httpd-${apache_latest_version}

/bin/mkdir /usr/local/apache2

#Get the list of custom modules we are building, if any at all

modules="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "APACHE" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/source//g'`"

#If we are configured with a custom list of modules, build with the modules otherwise perform our default build
if ( [ "${modules}" != "" ] )
then
   options=" --host=x86_64-pc-linux-gnu --target=x86_64-pc-linux-gnu --build=x86_64-pc-linux-gnu --prefix /usr/local/apache2 --sysconfdir=/etc/apache2 --enable-mods-shared=\"${modules}\" --enable-nonportable-atomics=yes --with-nghttp2 --enable-ssl --enable-so --enable-http2"
else
   options=" --host=x86_64-pc-linux-gnu --target=x86_64-pc-linux-gnu --build=x86_64-pc-linux-gnu --prefix /usr/local/apache2 --sysconfdir=/etc/apache2 --enable-mods-shared=all --enable-nonportable-atomics=yes --with-nghttp2 --enable-ssl --enable-so --enable-http2"  
fi

./configure ${options}

/usr/bin/make
/usr/bin/make install



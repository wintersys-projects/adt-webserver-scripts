#!/bin/sh
######################################################################################################
# Description: This will install and compile nginx from source code. This has the advantage that its
# the latest version of nginx will be used when sometimes repositories can use more dated versions.
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

buildtype="${1}"

export HOME=`/bin/cat /home/homedir.dat`
BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"

#Install needed libraries
if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
then
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get install  -o DPkg::Lock::Timeout=-1 -qq -y  build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev
fi

#Download the latest version of nginx
nginx_latest_version="`/usr/bin/curl 'http://nginx.org/download/' |   /bin/egrep -o 'nginx-[0-9]+\.[0-9]+\.[0-9]+' | /bin/sed 's/nginx-//g' |  /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"
/usr/bin/wget https://nginx.org/download/nginx-${nginx_latest_version}.tar.gz && /bin/tar zxvf nginx-${nginx_latest_version}.tar.gz
/bin/rm nginx-${nginx_latest_version}.tar.gz
cd nginx-${nginx_latest_version}

#Get the list of any custom modules that we want to compile with, if there are none, perform a default build
modules="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "NGINX" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/source//g'`"

if ( [ "${modules}" != "" ] )
then
    with_modules=""
    for module in ${modules}
    do
        with_modules=${with_modules}" --with-${module}_module"
    done
    options=" --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_realip_module --with-http_mp4_module ${with_modules}"
else
    options=" --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module --with-http_realip_module"
fi

./configure ${options}

/usr/bin/make
/usr/bin/make install

#Make nginx avaiable as a service and enable and start it
/bin/cp ${HOME}/installscripts/nginx/nginx.service /lib/systemd/system/nginx.service

/usr/bin/systemctl enable nginx
/usr/bin/systemctl restart nginx

cd ..
#Cleanup
/bin/rm -r nginx-${nginx_latest_version}





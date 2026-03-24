#!/bin/sh
#####################################################################################
# Description: This script will obtain and extract the sourcecode for joomla into 
# the webroot directory
# Author: Peter Winter
# Date: 04/01/2017
######################################################################################
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
######################################################################################
######################################################################################
#set -x

BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
${HOME}/installscripts/InstallWPCLI.sh ${BUILDOS}

webroot_directory="`/bin/grep "^WEBROOT_DIRECTORY:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${webroot_directory}" = "" ] )
then
        webroot_directory="/var/www/html/wordpress"
fi

if ( [ ! -d /var/www/html ] )
then
        /bin/mkdir -p /var/www/html
        /bin/chown www-data:www-data /var/www/html
        /bin/chmod 777 /var/www/html
fi

wordpress_version="`/bin/grep "^WORDPRESS_VERSION:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${wordpress_version}" = "" ] )
then
        wordpress_version="latest" 
fi

wordpress_locale="`/bin/grep "^WORDPRESS_LOCALE:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${wordpress_locale}" = "" ] )
then
        wordpress_locale="en_GB" 
fi

/bin/chmod 777 /var/www
/usr/bin/sudo -u www-data /usr/local/bin/wp core download --version=${wordpress_version} --path=${webroot_directory} --locale=${wordpress_locale} --force
/bin/chmod 755 /var/www
/bin/chmod 755 /var/www/html

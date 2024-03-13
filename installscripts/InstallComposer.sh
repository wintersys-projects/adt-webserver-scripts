#!/bin/sh
######################################################################################################
# Description: This script will install composer
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

if ( [ "${buildos}" = "ubuntu" ] )
then
    expected_checksum="$(/usr/bin/php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    /usr/bin/php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    actual_checksum="$(/usr/bin/php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$expected_checksum" != "$actual_checksum" ]
    then
        >&2 echo 'ERROR: Invalid installer checksum'
       /bin/rm composer-setup.php
       exit 1
   fi
   if ( [ -f ./composer-setup.php ] )
   then
       /usr/bin/php composer-setup.php --quiet
       /bin/rm composer-setup.php
   fi
   /bin/mv composer.phar ${HOME}/composer.phar
fi

if ( [ "${buildos}" = "debian" ] )
then
    expected_checksum="$(/usr/bin/php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    /usr/bin/php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    actual_checksum="$(/usr/bin/php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$expected_checksum" != "$actual_checksum" ]
    then
        >&2 echo 'ERROR: Invalid installer checksum'
       /bin/rm composer-setup.php
       exit 1
   fi
   if ( [ -f ./composer-setup.php ] )
   then
       /usr/bin/php composer-setup.php --quiet
       /bin/rm composer-setup.php
   fi
   /bin/mv composer.phar ${HOME}/composer.phar
fi

#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/07/2016
# Description: When this script runs it will write the joomla configuration file
# that exists in ${HOME}/runtime to the S3 datastore. The other webservers will then
# treat the file in the S3 datastore as authoritative and obtain it for themselves.
#####################################################################################
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
#######################################################################################
#######################################################################################
set -x
export HOME="`/bin/cat /home/homedir.dat`"
 
/usr/bin/php -ln ${HOME}/runtime/joomla_configuration.php
if ( [ "$?" != "0" ] )
then
        /bin/echo "Syntax error detected in your configuration file"
        exit
fi

if ( [ -f /var/www/html/configuration.php ] )
then
        /bin/cp /var/www/html/configuration.php ${HOME}/runtime/configuration.php.hold.$$
fi

/bin/mv ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
/bin/chown www-data:www-data /var/www/html/configuration.php
/bin/chmod 644 /var/www/html/configuration.php

if ( [ "`/usr/bin/curl -m 20 --insecure -I "https://localhost:443/index.php" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\|302\|303\"`" != "" ] ) 
then
        /bin/echo "I am distributing your suggested configuration file as I verified it suitable"
        /usr/bin/run ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/joomla_configuration.php joomla_configuration.php "no"
        /bin/rm ${HOME}/runtime/configuration.php.hold.$$
else
        /bin/echo "I am not distributing the configuration file you suggested, I found it to have a problem"
        /bin/echo "Your configuration remains as it originally was"
        /bin/mv ${HOME}/runtime/joomla_configuration.php.hold.$$ /var/www/html/configuration.php
        /bin/chown www-data:www-data /var/www/html/configuration.php
        /bin/chmod 644 /var/www/html/configuration.php
fi

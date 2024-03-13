#!/bin/sh
#######################################################################################
# Description: This script will install a moodle configuration. This creates a default
# configuration to bundled with the sourcecode which is used and customised for the particular
# deployment each time.
# Author: Peter Winter
# Date: 04/01/2017
#######################################################################################
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
#set -x

if ( [ -f /var/www/html/moodle/config.php ] )
then
    /bin/chown www-data:www-data /var/www/html/moodle/config.php
    /bin/chmod 600 /var/www/html/moodle/config.php
fi

if ( [ ! -f /var/www/html/moodle/config.php ] )
then
    /bin/cp /var/www/html/moodle/config-dist.php /var/www/html/moodle/config.php
    /bin/cp /var/www/html/moodle/config-dist.php ${HOME}/runtime/moodle_config.php
    /bin/cp /var/www/html/moodle/config-dist.php /var/www/html/moodle/config.php.default
    /bin/chown www-data:www-data /var/www/html/moodle/config.php
    /bin/chmod 600 /var/www/html/moodle/config.php
fi
    
if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/moodle-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data:www-data /var/www/html/.htaccess
    /bin/chmod 440 /var/www/html/.htaccess
fi
    
if ( [ ! -d /var/www/html/moodledata ] )
then
    /bin/mkdir -p /var/www/html/moodledata/filedir
    /bin/chmod -R 755 /var/www/html/moodledata
    /bin/chown -R www-data:www-data /var/www/html/moodledata
fi
    
/bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
/bin/echo "1"

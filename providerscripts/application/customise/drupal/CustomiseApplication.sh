#!/bin/sh
###########################################################################################################
# Description: Apply any customisations you want to make to drupal
# Author : Peter Winter
# Date: 17/05/2017
######################################################################################################
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
if ( [ -d /var/www/html/vendor.drupal ] )
then
    /bin/mv /var/www/html/vendor.drupal /var/www/vendor
    /bin/chown -R www-data:www-data /var/www/vendor
    /usr/bin/find /var/www/vendor -type d -print -exec chmod 755 {} \;
    /usr/bin/find /var/www/vendor -type f -print -exec chmod 644 {} \;
 fi

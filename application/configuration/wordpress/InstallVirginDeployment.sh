#!/bin/sh
#################################################################################
# Description: This script will obtain and extract the sourcecode for wordpress into 
# the webroot directory
# Author: Peter Winter
# Date: 04/01/2017
##################################################################################
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
##############################################################################
##############################################################################
#set -x

cd /var/www/html
/usr/bin/wget http://wordpress.org/latest.tar.gz
/bin/tar xvfz latest.tar.gz
/bin/rm latest.tar.gz
/bin/mv /var/www/html/wordpress/* /var/www/html
/bin/rmdir /var/www/html/wordpress
/bin/chown -R www-data:www-data /var/www/html/*
cd /home/${SERVER_USER}
/bin/echo "success"

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

cd /var/www/html
SOURCECODE_URL="`/bin/grep "^SOURCECODE_URL" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_URL://g' | /bin/sed 's/:/ /g'`"
SOURCECODE_MD5="`/bin/grep "^SOURCECODE_MD5" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_URL://g' | /bin/sed 's/:/ /g'`"
SOURCECODE_SHA1="`/bin/grep "^SOURCECODE_SHA1" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_URL://g' | /bin/sed 's/:/ /g'`"

/usr/bin/wget https://${SOURCECODE_URL}
/bin/echo "${0} `/bin/date`: Downloaded joomla from ${SOURCECODE_URL}" 

/usr/bin/python3 -m zipfile -e Joomla_*.zip /var/www/html/
/bin/rm Joomla_*.zip
/bin/chown -R www-data:www-data /var/www/html/*
cd ${HOME}
/bin/echo "success"

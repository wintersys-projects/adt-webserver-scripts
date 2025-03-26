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

version="`/bin/echo ${application} | /usr/bin/awk -F':' '{print $NF}'`"
cd /var/www/html
 
if ( [ "`/bin/echo ${version} | /bin/grep alpha`" != "" ] )
then
	/usr/bin/wget https://github.com/joomla/joomla-cms/releases/download/${version}/Joomla_${version}-Alpha-Full_Package.zip
	/bin/echo "${0} `/bin/date`: Downloaded an alpha version (${version}) of Joomla" 
	#/usr/bin/unzip Joomla_${version}-Alpha-Full_Package.zip
  	/usr/bin/python3 -m zipfile -e Joomla_${version}-Alpha-Full_Package.zip /var/www/html/
	/bin/rm Joomla_${version}-Alpha-Full_Package.zip
	/bin/mv /var/www/html/htaccess.txt /var/www/html/.htaccess
	/bin/chown -R www-data:www-data /var/www/html/*
	/bin/chmod 440 /var/www/html/.htaccess
	cd /home/${SERVER_USER}
	/bin/echo "success"
elif ( [ "`/bin/echo ${version} | /bin/grep beta`" != "" ] )
then
	/usr/bin/wget https://github.com/joomla/joomla-cms/releases/download/${version}/Joomla_${version}-Beta-Full_Package.zip
	/bin/echo "${0} `/bin/date`: Downloaded a beta version (${version}) of Joomla" 
	#/usr/bin/unzip Joomla_${version}-Beta-Full_Package.zip
	/usr/bin/python3 -m zipfile -e Joomla_${version}-Beta-Full_Package.zip /var/www/html/
	/bin/rm Joomla_${version}-Beta-Full_Package.zip
	/bin/chown -R www-data:www-data /var/www/html/*
	cd /home/${SERVER_USER}
	/bin/echo "success"
elif ( [ "`/bin/echo ${version} | /bin/grep rc`" != "" ] )
then
	/usr/bin/wget https://github.com/joomla/joomla-cms/releases/download/${version}/Joomla_${version}-Release_Candidate-Full_Package.zip
	/bin/echo "${0} `/bin/date`: Downloaded a rc version (${version}) of Joomla"
	#/usr/bin/unzip Joomla_${version}-Release_Candidate-Full_Package.zip
	/usr/bin/python3 -m zipfile -e Joomla_${version}-Release_Candidate-Full_Package.zip /var/www/html/
	/bin/rm Joomla_${version}-Release_Candidate-Full_Package.zip
	/bin/chown -R www-data:www-data /var/www/html/*
	cd /home/${SERVER_USER}
	/bin/echo "success"
else
	/usr/bin/wget https://github.com/joomla/joomla-cms/releases/download/${version}/Joomla_${version}-Stable-Full_Package.zip
	/bin/echo "${0} `/bin/date`: Downloaded a stable version (${version}) of Joomla" 
	#/usr/bin/unzip Joomla_${version}-Stable-Full_Package.zip
	/usr/bin/python3 -m zipfile -e Joomla_${version}-Stable-Full_Package.zip /var/www/html/
	/bin/rm Joomla_${version}-Stable-Full_Package.zip
	/bin/chown -R www-data:www-data /var/www/html/*
	cd /home/${SERVER_USER}
	/bin/echo "success"
fi


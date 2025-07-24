#!/bin/sh
###################################################################################
# Description: This script will obtain and extract the sourcecode for drupal into 
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
#################################################################################
#################################################################################
#set -x

HOME="`/bin/cat /home/homedir.dat`"

version="`/bin/echo ${application} | /usr/bin/awk -F':' '{print $NF}'`"

product="drupal"

if ( [ "`/bin/echo ${application} | /bin/grep 'social'`" != "" ] )
then
	product="social"
fi
if ( [ "`/bin/echo ${application} | /bin/grep 'cms'`" != "" ] )
then
	product="cms"
fi

if ( [ "${product}" = "drupal" ] )
then
	cd /var/www/html
	/usr/bin/wget https://ftp.drupal.org/files/projects/${product}-${version}.tar.gz
	/bin/tar xvfx ${product}-${version}.tar.gz
	/bin/rm ${product}-${version}.tar.gz
	/bin/mv ${product}-${version}/* .
	/bin/mv ${product}-${version}/.* . 2>/dev/null
	/bin/rm -r ${product}-${version}
	/bin/rm -r .git
	/bin/chown -R www-data:www-data /var/www/html/* /var/www/html/.*
	cd ${HOME}
	/bin/echo "success"
elif ( [ "${product}" = "social" ] )
then
        BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
        ${HOME}/installscripts/InstallComposer.sh ${BUILDOS}
        while ( [ ! -f ${HOME}/runtime/installedsoftware/InstallApplicationLanguage.sh ] )
        do
                /bin/sleep 5
        done
        /bin/rm -r /var/www/*
        /bin/mkdir /tmp/scratch.$$
        /bin/chmod 755 /tmp/scratch.$$
        /bin/chown www-data:www-data /tmp/scratch.$$
        /usr/bin/sudo -u www-data /usr/local/bin/composer create-project goalgorilla/social_template:dev-master /tmp/scratch.$$ --no-install --no-interaction --working-dir=/tmp/scratch.$$
   #     /bin/sed -i 's;"web-root": "web/";"web-root": "html/";' /tmp/scratch.$$/composer.json
   #     /bin/sed -i 's;web/;html/;' /tmp/scratch.$$/composer.json
        /bin/mv /tmp/scratch.$$/web /tmp/scratch.$$/html
        cd /tmp/scratch.$$
        /usr/bin/sudo -u www-data /usr/local/bin/composer update
        /usr/bin/sudo -u www-data /usr/local/bin/composer install
        /bin/mv * /var/www/
	cd ${HOME}
        /bin/echo "success"
elif ( [ "${product}" = "cms" ] )
then
	BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
	${HOME}/installscripts/InstallComposer.sh ${BUILDOS}
	/bin/rm -r /var/www/*
	/bin/mkdir /tmp/scratch.$$
	/bin/chmod 755 /tmp/scratch.$$
	/bin/chown www-data:www-data /tmp/scratch.$$
	/usr/bin/sudo -u www-data /usr/local/bin/composer create-project drupal/cms /tmp/scratch.$$ --no-install --no-interaction --working-dir=/tmp/scratch.$$
	/bin/sed -i 's;"web-root": "web/";"web-root": "html/";' /tmp/scratch.$$/composer.json
	/bin/sed -i 's;web/;html/;' /tmp/scratch.$$/composer.json
	/bin/mv /tmp/scratch.$$/web /tmp/scratch.$$/html
	cd /tmp/scratch.$$
	/usr/bin/sudo -u www-data /usr/local/bin/composer install 
	/bin/mv * /var/www/
 	cd ${HOME}
	/bin/echo "success"
fi

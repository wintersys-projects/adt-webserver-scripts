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

if ( [ "`/bin/grep "^APPLICATION_TYPE:drupal" ${HOME}/runtime/application.dat`" != "" ] )
then
	cd ${HOME}
	BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
	${HOME}/installscripts/InstallComposer.sh ${BUILDOS}
	/bin/rm -r /var/www/*
	/bin/chown www-data:www-data /var/www
	drupal_version="`/bin/grep "^DRUPAL_VERSION:" ${HOME}/runtime/application.dat | /bin/sed 's/^DRUPAL_VERSION://g'`"
	/usr/bin/sudo -u www-data /usr/local/bin/composer create-project ${drupal_version} /var/www/html --no-interaction 
	cd /var/www/html
	/usr/bin/sudo -u www-data /usr/local/bin/composer require drush/drush --no-interaction 
	/usr/bin/ln -s /var/www/html/vendor/bin/drush /usr/sbin/drush
    /bin/chmod 755 /var/www/html/vendor/bin/drush.php
    /bin/chmod 755 /var/www/html/vendor/drush/drush/drush
    cd ${HOME}
    /bin/echo "success"
elif ( [ "`/bin/grep "^APPLICATION_TYPE:cms" ${HOME}/runtime/application.dat`" != "" ] )
then
	cd ${HOME}
	BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
	${HOME}/installscripts/InstallComposer.sh ${BUILDOS}
	/bin/rm -r /var/www/*
	/bin/chown www-data:www-data /var/www
	cms_version="`/bin/grep "^CMS_VERSION:" ${HOME}/runtime/application.dat | /bin/sed 's/^CMS_VERSION://g'`"
	/usr/bin/sudo -u www-data /usr/local/bin/composer create-project ${cms_version} /var/www/html --no-interaction 
	cd /var/www/html
	/usr/bin/sudo -u www-data /usr/local/bin/composer require drush/drush --no-interaction 
	/usr/bin/ln -s /var/www/html/vendor/bin/drush /usr/sbin/drush
    /bin/chmod 755 /var/www/html/vendor/bin/drush.php
    /bin/chmod 755 /var/www/html/vendor/drush/drush/drush
    cd ${HOME}
    /bin/echo "success"
fi

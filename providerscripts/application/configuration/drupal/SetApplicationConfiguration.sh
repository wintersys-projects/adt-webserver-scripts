#!/bin/sh
####################################################################################
# Description: This script will update update the configration for drupal
# Author: Peter Winter
# Date: 05/01/2017
####################################################################################
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
#####################################################################################
#####################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
	exit
fi

if ( [ ! -f ${HOME}/runtime/DRUPAL_CONFIG_SET ] && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh drupal_settings.php`" != "" ] )
then	
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh drupal_settings.php ${HOME}/runtime/drupal_settings.php
 	if ( [ -f /var/www/html/sites/default/settings.php ] )
  	then
   		/bin/rm /var/www/html/sites/default/settings.php
	fi
 	/bin/cp ${HOME}/runtime/drupal_settings.php /var/www/html/sites/default/settings.php
  	/bin/touch ${HOME}/runtime/DRUPAL_CONFIG_SET
fi

exit

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh drupal_settings.php`" != "" ] )
then
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh drupal_settings.php ${HOME}/runtime/drupal_settings.php
fi

if ( [ ! -f ${HOME}/runtime/CONFIG_PRIMED ] && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh drupal_settings.php`" = "" ] )
then
	${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/www/html/sites/default/settings.php
	if ( [ "$?" = "0" ] )
 	then
  		/bin/touch ${HOME}/runtime/CONFIG_PRIMED
	fi
fi

if ( [ ! -f ${HOME}/runtime/DRUPAL_CONFIG_SET ] && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh drupal_settings.php`" != "" ] )
then	
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh drupal_settings.php ${HOME}/runtime/drupal_settings.php
 	if ( [ -f /var/www/html/sites/default/settings.php ] )
  	then
   		/bin/rm /var/www/html/sites/default/settings.php
	fi
 	/bin/cp ${HOME}/runtime/drupal_settings.php /var/www/html/sites/default/settings.php
  	/bin/touch ${HOME}/runtime/DRUPAL_CONFIG_SET
elif ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh drupal_settings.php`" != "" ] )
then
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh drupal_settings.php ${HOME}/runtime/drupal_settings.php.$$
	if ( [ "`/usr/bin/diff ${HOME}/runtime/drupal_settings.php.$$ /var/www/html/sites/default/settings.php`" != "" ] )
	then
		/bin/cp ${HOME}/runtime/drupal_settings.php.$$ ${HOME}/runtime/drupal_settings.php
		/bin/mv ${HOME}/runtime/drupal_settings.php.$$ /var/www/html/sites/default/settings.php
  	else
   		/bin/rm ${HOME}/runtime/drupal_settings.php.$$
	fi
fi

if ( [ -f /var/www/html/sites/default/settings.php ] )
then
	/bin/chown www-data:www-data /var/www/html/sites/default/settings.php
	/bin/chmod 600 /var/www/html/sites/default/settings.php
fi

if ( [ ! -f ${HOME}/runtime/DB_PREFIX_SET ] )
then
	dbprefix="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*  | /usr/bin/awk -F':' '{print $NF}'`"

	if ( [ "${dbprefix}" = "" ] )
	then
		dbprefix="`/bin/cat /var/www/html/dbp.dat`"
	fi
 
	${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh DBPREFIX:${dbprefix}
 	/bin/touch ${HOME}/runtime/DB_PREFIX_SET
fi


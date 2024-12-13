#!/bin/sh
##################################################################################
# Description: This script will update update the database credentials for moodle
# Author: Peter Winter
# Date: 05/01/2017
###################################################################################
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
#set -x
 
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
	exit
fi

if ( [ ! -f ${HOME}/runtime/MOODLE_CONFIG_SET ] && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh moodle_config.php`" != "" ] )
then	
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh moodle_config.php ${HOME}/runtime/moodle_config.php
   
 	if ( [ -f /var/www/html/moodle/config.php ] )
  	then
   		/bin/rm /var/www/html/moodle/config.php
	fi
 	
  	/bin/cp ${HOME}/runtime/moodle_config.php /var/www/html/moodle/config.php
  	/bin/touch ${HOME}/runtime/MOODLE_CONFIG_SET
fi

exit

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh moodle_config.php`" != "" ] )
then
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh moodle_config.php ${HOME}/runtime/moodle_config.php
fi

if ( [ ! -f ${HOME}/runtime/CONFIG_PRIMED ] && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh confign.php`" = "" ] )
then
	${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/www/html/moodle/config.php
	if ( [ "$?" = "0" ] )
 	then
  		/bin/touch ${HOME}/runtime/CONFIG_PRIMED
	fi
fi

if ( [ ! -f ${HOME}/runtime/MOODLE_CONFIG_SET ] && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh moodle_config.php`" != "" ] )
then	
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh moodle_config.php ${HOME}/runtime/moodle_config.php
   
 	if ( [ -f /var/www/html/moodle/config.php ] )
  	then
   		/bin/rm /var/www/html/moodle/config.php
	fi
 	
  	/bin/cp ${HOME}/runtime/moodle_config.php /var/www/html/moodle/config.php
  	/bin/touch ${HOME}/runtime/MOODLE_CONFIG_SET
elif ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh moodle_config.php`" != "" ] )
then
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh moodle_config.php ${HOME}/runtime/moodle_config.php.$$
	if ( [ "`/usr/bin/diff ${HOME}/runtime/moodle_config.php.$$ /var/www/html/moodle/config.php`" != "" ] )
	then
		/bin/cp ${HOME}/runtime/moodle_config.php.$$ ${HOME}/runtime/moodle_config.php
		/bin/mv ${HOME}/runtime/moodle_config.php.$$ /var/www/html/moodle/config.php
  	else
   		/bin/rm ${HOME}/runtime/moodle_config.php.$$
	fi
fi

if ( [ -f /var/www/html/moodle/config.php ] )
then
	/bin/chown www-data:www-data /var/www/html/moodle/config.php
	/bin/chmod 600 /var/www/html/moodle/config.php
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





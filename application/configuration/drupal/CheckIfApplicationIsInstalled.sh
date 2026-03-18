#!/bin/sh
###########################################################################################################
# Description:Check if a drupal application has been installed
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
#set -x #do not set this during a live deployment the application will fail to install

installed="1"
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then	
	directories="`/bin/grep "^APPLICATION_INTEGRITY_DIRECTORIES" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_INTEGRITY_DIRECTORIES://g' | /bin/sed 's/:/ /g'`"
	for directory in ${directories}
	do
		if ( [ ! -d /var/www/html/${directory} ] )
		then
			installed="0"
		fi
	done
	
	files="`/bin/grep "^APPLICATION_INTEGRITY_FILES" ${HOME}/runtime/application.dat | /bin/sed 's/APPLICATION_INTEGRITY_FILES://g' | /bin/sed 's/:/ /g'`"
	for file in ${files}
	do
		if ( [ ! -f /var/www/html/${file} ] )
		then
			installed="0"
		fi
	done
	
	if ( [ ! -f /usr/local/bin/composer ] )
	then
		BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
		${HOME}/installscripts/InstallComposer.sh ${BUILDOS}
	fi
	
	if ( [ ! -f /usr/sbin/drush ] )
	then
		cd /var/www/html
		/usr/bin/sudo -u www-data /usr/local/bin/composer require drush/drush
		/bin/ln -s /var/www/html/vendor/bin/drush /usr/sbin/drush
		/bin/chown www-data:www-data /usr/sbin/drush
		/bin/chmod 644 /usr/sbin/drush
	fi
	
	if ( [ ! -f /usr/sbin/drush ] )
	then
			installed="0"
	fi
fi

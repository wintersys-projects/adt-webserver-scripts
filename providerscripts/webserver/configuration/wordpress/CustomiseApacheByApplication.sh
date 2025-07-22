###########################################################################################################
# Description: This will customise that Apache configuration file for wordpress
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
#set -x

HOME="`/bin/cat /home/homedir.dat`"

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"

if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'APACHE:source'`" = "1" ] )
then
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/wordpress/apache/online/source/htaccess-main.conf ] )	
	then
		/bin/cp ${HOME}/providerscripts/webserver/configuration/wordpress/apache/online/source/htaccess-main.conf /var/www/html/.htaccess
		/bin/chmod 444 /var/www/html/.htaccess
		/bin/chown www-data:www-data /var/www/html/.htaccess
	fi

	if ( [ -f ${HOME}/providerscripts/webserver/configuration/wordpress/apache/online/source/htaccess-uploads.conf ] )	
	then
		if ( [ ! -d /var/www/html/wp-content/uploads ] )
		then
			/bin/mkdir -p /var/www/html/wp-content/uploads
 			/bin/chmod -R 755 /var/www/html/wp-content/uploads
			/bin/chown -R www-data:www-data /var/www/html/wp-content/uploads
		fi

		/bin/cp ${HOME}/providerscripts/webserver/configuration/wordpress/apache/online/source/htaccess-uploads.conf /var/www/html/wp-content/uploads/.htaccess
		/bin/chmod 444 /var/www/html/wp-content/uploads/.htaccess
		/bin/chown www-data:www-data /var/www/html/wp-content/uploads/.htaccess
	fi
else
	if ( [ -f ${HOME}/providerscripts/webserver/configuration/wordpress/apache/online/repo/htaccess-main.conf ] )	
	then
		/bin/cp ${HOME}/providerscripts/webserver/configuration/wordpress/apache/online/repo/htaccess-main.conf /var/www/html/.htaccess
		/bin/chmod 444 /var/www/html/.htaccess
		/bin/chown www-data:www-data /var/www/html/.htaccess
	fi

	if ( [ -f ${HOME}/providerscripts/webserver/configuration/wordpress/apache/online/repo/htaccess-uploads.conf ] )	
	then
		if ( [ ! -d /var/www/html/wp-content/uploads ] )
		then
			/bin/mkdir -p /var/www/html/wp-content/uploads
 			/bin/chmod -R 755 /var/www/html/wp-content/uploads
			/bin/chown -R www-data:www-data /var/www/html/wp-content/uploads
		fi

		/bin/cp ${HOME}/providerscripts/webserver/configuration/wordpress/apache/online/repo/htaccess-uploads.conf /var/www/html/wp-content/uploads/.htaccess
		/bin/chmod 444 /var/www/html/wp-content/uploads/.htaccess
		/bin/chown www-data:www-data /var/www/html/wp-content/uploads/.htaccess
	fi

fi








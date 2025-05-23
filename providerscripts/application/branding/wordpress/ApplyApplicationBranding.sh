#!/bin/sh
###########################################################################################################
# Description: When you make a baseline of an application, deployment specific values are replaced with generic
# placeholder values throughout the files in your webroot. This is "removing the application branding". When you
# deploy from the baseline again the generic placeholders are replaced with deployment specific values again and 
# that is what this script does. This makes it possible for the same baseline to be deployed with different
# application branding
# Author: Peter Winter
# Date : 09/12/2017
###########################################################################################################
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
 
domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"

/bin/echo "Customising your application. This may take a bit of time...."
/usr/bin/find /var/www/html -type f -exec sed -i -e "s/ApplicationDomainSpec/${domainspecifier}/g" -e "s/applicationdomainwww.tld/${WEBSITE_URL}/g" -e "s/applicationrootdomain.tld/${ROOT_DOMAIN}/g" -e "s/The GreatApplication/${WEBSITE_DISPLAY_NAME}/g" -e "s/THE GREATAPPLICATION/${WEBSITE_DISPLAY_NAME_UPPER}/g" -e "s/GREATAPPLICATION/${WEBSITE_DISPLAY_NAME_UPPER}/g" -e  "s/GreatApplication/${WEBSITE_DISPLAY_NAME}/g" -e "s/greatapplication/${WEBSITE_DISPLAY_NAME_LOWER}/g" -e "s/Greatapplication/${WEBSITE_DISPLAY_NAME_FIRST}/g" {} \;

if ( [ ! -d /var/www/html/wp-content/uploads ] )
then
	/bin/mkdir -p /var/www/html/wp-content/uploads
fi


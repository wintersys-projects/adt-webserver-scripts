#!/bin/sh
###########################################################################################################
# Description: When you make extract a backup of your webroot, you extract out generic placeholder values
# from your webroot archive, you can then change these generic valued placeholders with deployment specific values.
# When you "RemoveApplicationBranding" as you make a backup, specific values are replaced with generic placeholders
# and here is where these generic placeholders can be replaced with deployment specific values again. 
# For example, when a backups are made, "WEBSITE_DISPLAY_NAME" is replaced with the word "GreatApplication"
# and so this is what makes it possible to port the same webroot to different deployments
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


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

HOME="`/bin/cat /home/homedir.dat`"

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"

WEBSITE_NAME_UPPER="`/bin/echo ${WEBSITE_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_NAME_LOWER="`/bin/echo ${WEBSITE_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
WEBSITE_NAME_FIRST="`/bin/echo ${WEBSITE_NAME_LOWER} | /bin/sed -e 's/\b\(.\)/\u\1/g'`"


domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"

/bin/echo "Customising your application. This may take a bit of time...."
/usr/bin/find /var/www/html -type f -exec sed -i -e "s/ApplicationDomainSpec/${domainspecifier}/g" -e "s/applicationdomainwww.tld/${WEBSITE_URL}/g" -e "s/applicationrootdomain.tld/${ROOT_DOMAIN}/g" -e "s/The GreatApplication/${WEBSITE_NAME}/g" -e "s/THE GREATAPPLICATION/${WEBSITE_NAME_UPPER}/g" -e "s/GREATAPPLICATION/${WEBSITE_NAME_UPPER}/g" -e  "s/GreatApplication/${WEBSITE_NAME}/g" -e "s/greatapplication/${WEBSITE_NAME_LOWER}/g" -e "s/Greatapplication/${WEBSITE_NAME_FIRST}/g" {} \;

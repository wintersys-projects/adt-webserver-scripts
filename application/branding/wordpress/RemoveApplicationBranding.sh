#!/bin/sh
###########################################################################################################
# Description: When we baseline an appplication we have developed we don't want to be stuck with the
# branding that we gave it during development so this script removes all the application's branding and 
# replaces it with generic placeholders which can then be substituted for when the baseline is deployed
# by a 3rd party
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
HOME="`/bin/cat /home/homedir.dat`"

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
WEBSITE_DISPLAY_NAME_FIRST="`/bin/echo ${WEBSITE_DISLAY_NAME_LOWER} | /bin/sed -e 's/\b\(.\)/\u\1/g'`"
domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"

/usr/bin/find . -type f -exec sed -i -e "s/${domainspecifier}/ApplicationDomainSpec/g" -e "s/${WEBSITE_URL}/applicationdomainwww.tld/g" -e "s/${ROOT_DOMAIN}/applicationrootdomain.tld/g" -e "s/${WEBSITE_DISPLAY_NAME}/The GreatApplication/g" -e "s/${WEBSITE_DISPLAY_NAME_UPPER}/THE GREATAPPLICATION/g" -e "s/${WEBSITE_DISPLAY_NAME}/GreatApplication/g" -e "s/${WEBSITE_DISPLAY_NAME_UPPER}/GREATAPPLICATION/g" -e "s/${WEBSITE_DISPLAY_NAME_LOWER}/greatapplication/g" -e "s/${WEBSITE_DISPLAY_NAME_FIRST}/Greatapplication/g" {} \;


#!/bin/sh
###########################################################################################################
# Description: This will generate a one time link to a file allowing the user to input their IP address
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

email_list="`/bin/cat /var/www/html/emails.dat | /usr/bin/awk -F':' '{print $NF}'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_URL_ORIGINAL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURLORIGINAL'`"

for email_address in ${email_list}
do
	password="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-8`"
  password="`/bin/echo -n "${email_address}:${password}" | /usr/bin/base64`"

	website_url="https://${WEBSITE_URL}/ip-address-${file_name}.php"
	message="<!DOCTYPE html> <html> <body> I have generated a password for as requested for website: ${WEBSITE_URL_ORIGINAL}.<br> Your password is: ${password} </body> </html>"
	${HOME}/providerscripts/email/SendEmail.sh "Access Credentials for this email address at ${WEBSITE_URL_ORIGINAL}" "${message}" MANDATORY ${email_address} "HTML" "AUTHENTICATION"
done

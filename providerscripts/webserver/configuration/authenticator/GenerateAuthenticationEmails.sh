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
	file_name="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
	full_file_name="/var/www/html/ip-address-${file_name}.php"
	/bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/ip-collector.php ${full_file_name}
	/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL_ORIGINAL}/g" ${full_file_name}
	/bin/chown www-data:www-data ${full_file_name}
	/bin/chmod 644 ${full_file_name}
	website_url="https://${WEBSITE_URL}/ip-address-${file_name}.php"
	message="<!DOCTYPE html> <html> <body> <h1>IP address authorisation form for ${WEBSITE_URL_ORIGINAL}</h1> <p>From the SAME browser as you want to connect from (your phone broswer might have a different ip address to your laptop if one is on WIFI and one is on 5G go to www.whatsmyip.com and enter the IPV4 IP address in the form that appears when you click the link below. Cheers. This link will be valid for 5 minutes before being deleted. </p> <a href='"${website_url}"'>Enable Your IP Address</a> </body> </html>"
	${HOME}/providerscripts/email/SendEmail.sh "Authenticated IP claim request for ${WEBSITE_URL_ORIGINAL}" "${message}" MANDATORY ${email_address} "HTML" "AUTHENTICATION"
	/bin/sed -i "/:${email_address}$/d" /var/www/html/emails.dat
done

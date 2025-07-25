#!/bin/sh
###########################################################################################################
# Description: This will accept an ip address that has been generated by a user inputing their laptop's
# IP address into the HTML form in reponse to a one time link to it
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

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURLORIGINAL'`"

if ( [ ! -d ${HOME}/runtime/authenticator ] )
then
	/bin/mkdir -p ${HOME}/runtime/authenticator 
fi

/bin/touch ${HOME}/runtime/authenticator/ipaddresses.da

if ( [ -f /var/www/html/ipaddresses.dat ] )
then
	for ip_address in `/bin/cat /var/www/html/ipaddresses.dat | /usr/bin/awk -F':' '{print $NF}'`
	do
		if ( [ "`/usr/bin/expr "${ip_address}" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$'`"  != "0" ] )
		then
			if ( [ "`/bin/grep ${ip_address} ${HOME}/runtime/authenticator/ipaddresses.dat`" = "" ] )
			then
				/bin/echo "${ip_address}" >> ${HOME}/runtime/authenticator/ipaddresses.dat
				if ( [ "${MULTI_REGION}" = "1" ] )
				then
					multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
					${HOME}/providerscripts/datastore/PutToDatastore.sh ${ip_address} ${multi_region_bucket}/multi-region-auth-laptop-ips/${ip_address}
				fi
			fi
		fi
	done
fi

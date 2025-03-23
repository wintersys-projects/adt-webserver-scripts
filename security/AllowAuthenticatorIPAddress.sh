#!/bin/sh
#################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Connect to the Database Server machine (linux)
#################################################################################
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
#####################################################################################
#####################################################################################
#set -x

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
HOST="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh authenticatorip/*`"
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
HOME="`/bin/cat /home/homedir.dat`"

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh ACTIVEFIREWALLS:1`" = "0" ] && [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh ACTIVEFIREWALLS:3`" = "0" ] )
then
	exit
fi

firewall=""
if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "FIREWALL" | /usr/bin/awk -F':' '{print $NF}'`" = "ufw" ] )
then
	firewall="ufw"
elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "FIREWALL" | /usr/bin/awk -F':' '{print $NF}'`" = "iptables" ] )
then
	firewall="iptables"
fi

if ( [ ! -d ${HOME}/runtime/authenticator ] )
then
	/bin/mkdir ${HOME}/runtime/authenticator
fi

if ( [ ! -f ${HOME}/runtime/authenticator/ipaddress.dat ] )
then
	/usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -P ${SSH_PORT} ${SERVER_USER}@${HOST}:${HOME}/runtime/authenticator/ipaddresses.dat ${HOME}/runtime/authenticator/ipaddresses.dat.$$

	for ip_address in `/bin/cat ${HOME}/runtime/authenticator/ipaddresses.dat.$$`
	do
		if ( [ "`/bin/grep ${ip_address} ${HOME}/runtime/authenticator/ipaddresses.dat`" = "" ] )
		then
			if ( [ "${firewall}" = "ufw" ] )
			then
				/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip_address} to any port 443
				/bin/echo "${ip_address}" >> ${HOME}/runtime/authenticator/ipaddresses.dat
			elif ( [ "${firewall}" = "iptables" ] )
			then
				/usr/sbin/iptables -A INPUT -s ${ip_address} -p tcp --dport 443 -j ACCEPT
				/bin/echo "${ip_address}" >> ${HOME}/runtime/authenticator/ipaddresses.dat
			fi
		fi
	done
	/bin/rm ${HOME}/runtime/authenticator/ipaddresses.dat.$$
fi

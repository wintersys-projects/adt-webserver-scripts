#!/bin/sh
#################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: If a machine has been allowed access by an authenticator machine
# then allow its ip address through the firewall now
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

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "authenticatorip/*" | /usr/bin/tr '\n' ' '`"
BUILD_IDENTIFIER="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

HOME="`/bin/cat /home/homedir.dat`"

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh ACTIVEFIREWALLS:1`" = "0" ] && [ "`${HOME}/utilities/config/CheckConfigValue.sh ACTIVEFIREWALLS:3`" = "0" ] )
then
        exit
fi

firewall=""
if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "FIREWALL" | /usr/bin/awk -F':' '{print $2}'`" = "ufw" ] )
then
        firewall="ufw"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "FIREWALL" | /usr/bin/awk -F':' '{print $2}'`" = "iptables" ] )
then
        firewall="iptables"
fi

if ( [ "`/usr/sbin/iptables --list-rules | /bin/grep allowed-laptop-ips`" = "" ] )
then
        ${HOME}/installscripts/InstallIPSet.sh ${BUILDOS}
        /usr/sbin/ipset create allowed-laptop-ips hash:ip maxelem 16777216
        /usr/sbin/iptables -I INPUT -m set --match-set allowed-laptop-ips src -p tcp --dport 443 -j ACCEPT
fi

if ( [ ! -d ${HOME}/runtime/authenticator ] )
then
        /bin/mkdir ${HOME}/runtime/authenticator
fi

${HOME}/providerscripts/datastore/operations/SyncFromDatastore.sh "firewall-auth" "root" "${HOME}/runtime/authenticator"

if ( [ -f ${HOME}/runtime/authenticator/ipaddresses.dat ] )
then
        /bin/mv ${HOME}/runtime/authenticator/ipaddresses.dat ${HOME}/runtime/authenticator/$$.ipaddresses.dat
fi

/bin/cat ${HOME}/runtime/authenticator/ipaddresses.dat* > ${HOME}/runtime/authenticator/ipaddresses.dat

for ip_address in `/bin/cat ${HOME}/runtime/authenticator/ipaddresses.dat`
do
        if ( [ "`/bin/grep ${ip_address} ${HOME}/runtime/authenticator/$$.ipaddresses.dat`" = "" ] )
        then
                if ( [ "${firewall}" = "ufw" ] )
                then
                        /usr/sbin/ipset add allowed-laptop-ips "${ip_address}/32"
                        /usr/sbin/ufw reload
                        /bin/echo "${ip_address}" >> ${HOME}/runtime/authenticator/ipaddresses.dat
                elif ( [ "${firewall}" = "iptables" ] )
                then
                        /usr/sbin/ipset add allowed-laptop-ips ${ip_address}
                        /bin/echo "${ip_address}" >> ${HOME}/runtime/authenticator/ipaddresses.dat
                fi
        fi
done

if ( [ -f ${HOME}/runtime/authenticator/$$.ipaddresses.dat ] )
then
        /bin/rm ${HOME}/runtime/authenticator/$$.ipaddresses.dat
fi

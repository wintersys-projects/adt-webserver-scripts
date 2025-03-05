#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Setup the firewall
#####################################################################################
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
##################################################################################
##################################################################################
set -x 
###################################################################################

export HOME="`/bin/cat /home/homedir.dat`"

if ( [ -f ${HOME}/runtime/FIREWALL-ACTIVE ] )
then
        exit
fi

if ( [ ! -d ${HOME}/logs/firewall ] )
then
        /bin/mkdir -p ${HOME}/logs/firewall
fi

#if ( [ ! -f ${HOME}/runtime/WEBSERVER_READY ] )
#then
#   exit
#fi

#exec >${HOME}/logs/firewall/FIREWALL_CONFIGURATION.log
#exec 2>&1
##################################################################################

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

if ( [ "${firewall}" = "ufw" ] && [ ! -f ${HOME}/runtime/FIREWALL-ACTIVE ] )
then
	/usr/bin/yes | /usr/sbin/ufw reset
  	/usr/sbin/ufw delete allow 22/tcp
 	/bin/sed -i "s/IPV6=yes/IPV6=no/g" /etc/default/ufw
        /usr/sbin/ufw logging off
	/usr/sbin/ufw reload
fi

BUILD_CLIENT_IP="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDCLIENTIP'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
CLOUDHOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"
DNS_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
VPC_IP_RANGE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'VPCIPRANGE'`"

${HOME}/security/KnickersUp.sh

updated="0"

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDMACHINEVPC:0`" = "1" ] )
then
        if ( [ "${firewall}" = "ufw" ] )
        then
                if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${BUILD_CLIENT_IP} | /bin/grep ALLOW`" = "" ] )
                then
                        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${BUILD_CLIENT_IP} to any port ${SSH_PORT}
                        updated="1"
                fi
        elif ( [ "${firewall}" = "iptables" ] )
        then
                if ( [ "`/usr/sbin/iptables --list-rules | /bin/grep ACCEPT | /bin/grep ${SSH_PORT} | /bin/grep ${BUILD_CLIENT_IP}`" = "" ] )
                then
                        /usr/sbin/iptables -A INPUT -s ${BUILD_CLIENT_IP} -p tcp --dport ${SSH_PORT} -j ACCEPT
                        /usr/sbin/iptables -A INPUT -s ${BUILD_CLIENT_IP} -p ICMP --icmp-type 8 -j ACCEPT
                        updated="1"
                fi
        fi
fi



if ( [ "${firewall}" = "ufw" ] )
then
        if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep "${VPC_IP_RANGE}" | /bin/grep ALLOW`" = "" ] )
        then
                /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${VPC_IP_RANGE} to any port ${SSH_PORT}
                /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${VPC_IP_RANGE} to any port 443
                updated="1"
        fi
elif ( [ "${firewall}" = "iptables" ] )
then
        if ( [ "`/usr/sbin/iptables --list-rules | /bin/grep ACCEPT | /bin/grep ${SSH_PORT} | /bin/grep ${VPC_IP_RANGE}`" = "" ] )
        then
                /usr/sbin/iptables -A INPUT -s ${VPC_IP_RANGE} -p tcp --dport ${SSH_PORT} -j ACCEPT
                /usr/sbin/iptables -A INPUT -s ${VPC_IP_RANGE} -p tcp --dport 443 -j ACCEPT
                /usr/sbin/iptables -A INPUT -s ${VPC_IP_RANGE} -p ICMP --icmp-type 8 -j ACCEPT
                updated="1"
        fi
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh AUTHENTICATIONSERVER:1`" != "1" ] && [ "`/usr/bin/hostname | /bin/grep '^auth'`" = "" ] )
then
	if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
	then
        	if ( [ "${firewall}" = "ufw" ] )
        	then
                	for ip in `/usr/bin/curl https://www.cloudflare.com/ips-v4/#`
                	do
                        	if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep "${ip}" | /bin/grep ALLOW`" = "" ] )
                        	then
                                	/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port 443
                                	updated="1"
                        	fi
                	done
        	elif ( [ "${firewall}" = "iptables" ] )
        	then
                	for ip in `/usr/bin/curl https://www.cloudflare.com/ips-v4/#`
                	do
                        	if ( [ "`/usr/sbin/iptables --list-rules | /bin/grep ACCEPT | /bin/grep 443 | /bin/grep ${ip}`" = "" ] )
                        	then
                                	/usr/sbin/iptables -A INPUT -s ${ip} -p tcp --dport 443 -j ACCEPT
                                	updated="1"
                        	fi
                	done
        	fi
	fi


	if ( [ "${DNS_CHOICE}" = "digitalocean" ] || [ "${DNS_CHOICE}" = "exoscale" ] || [ "${DNS_CHOICE}" = "linode" ] || [ "${DNS_CHOICE}" = "vultr" ]  )
	then
        	if ( [ "${firewall}" = "ufw" ] )
        	then
                	/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow 443/tcp
                	updated="1"
        	elif ( [ "${firewall}" = "iptables" ] )
        	then
                	/usr/sbin/iptables -A INPUT -p tcp --dport 443 -j ACCEPT
                	updated="1" 
        	fi
	fi
fi

#if ( [ "${DNS_CHOICE}" = "exoscale" ] )
#then
#        if ( [ "${firewall}" = "ufw" ] )
#        then
#                /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow 443/tcp
#                updated="1"
#        elif ( [ "${firewall}" = "iptables" ] )
#        then
#                /usr/sbin/iptables -I INPUT -p tcp --dport 443 -j ACCEPT
#                updated="1" 
#        fi
#fi

#if ( [ "${DNS_CHOICE}" = "linode" ] )
#then
#        if ( [ "${firewall}" = "ufw" ] )
#        then
#                /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow 443/tcp
#                updated="1"
#        elif ( [ "${firewall}" = "iptables" ] )
#        then
#                /usr/sbin/iptables -I INPUT -p tcp --dport 443 -j ACCEPT
#                updated="1" 
#        fi
#fi

#if ( [ "${DNS_CHOICE}" = "vultr" ] )
#then
#        if ( [ "${firewall}" = "ufw" ] )
#        then
#                /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow 443/tcp
#                updated="1"
#        elif ( [ "${firewall}" = "iptables" ] )
#        then
#                /usr/sbin/iptables -I INPUT -p tcp --dport 443 -j ACCEPT
#                updated="1" 
#        fi
#fi

if ( [ "${updated}" = "1" ] )
then
        if ( [ "${firewall}" = "ufw" ] )
        then
                /usr/sbin/ufw -f enable
                /usr/sbin/ufw reload
              #  ${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh systemd-networkd.service restart
		${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh NetworkManager restart || ${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh systemd-networkd.service restart
        elif ( [ "${firewall}" = "iptables" ] )
        then
		/usr/sbin/netfilter-persistent save
        fi
fi

if ( [ "${firewall}" = "ufw" ] )
then
        if ( [ "`/usr/bin/ufw status | /bin/grep 'inactive'`" = "" ] )
        then
                /bin/touch ${HOME}/runtime/FIREWALL-ACTIVE
        fi
elif ( [ "${firewall}" = "iptables" ] )
then
        if ( [ "`${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh netfilter-persistent status | /bin/grep Loaded | /bin/grep enabled`" != "" ] )
        then
                if ( [ "`${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh netfilter-persistent status | /bin/grep active`" != "" ] )
                then
                        /bin/touch ${HOME}/runtime/FIREWALL-ACTIVE
                fi
        fi
fi

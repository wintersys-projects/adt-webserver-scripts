#!/bin/sh
#####################################################################################
# Description: This is a script which will use the acme.sh client to generate an SSL 
# Certificate in response to a cerificate expiration event. 
#
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
#######################################################################################################
#######################################################################################################
#set -x

status () {
        /bin/echo "${1}" | /usr/bin/tee /dev/fd/3 2>/dev/null
        script_name="`/bin/echo ${0} | /usr/bin/awk -F'/' '{print $NF}'`"
        /bin/echo "${script_name}: ${1}" | /usr/bin/tee -a /dev/fd/4 2>/dev/null
}

BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
SSL_LIVE_CERT="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSLLIVECERT'`"
DNS_USERNAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSUSERNAME'`"
DNS_SECURITY_KEY="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSSECURITYKEY'`"
DNS_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
SSL_GENERATION_SERVICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSLGENERATIONSERVICE'`"

if ( [ "${SSL_GENERATION_SERVICE}" = "ZEROSSL" ] )
then
        server="zerossl"
fi

if ( [ "${SYSTEM_FROMEMAIL_ADDRESS}" = "" ] )
then
        SYSTEM_FROMEMAIL_ADDRESS="${DNS_USERNAME}"
fi

if ( [ -d ~/.acme.sh ] )
then
        /bin/rm -r ~/.acme.sh
fi

if ( [ ! -f ~/.acme.sh/acme.sh ] )
then
        ${HOME}/installscripts/InstallSocat.sh ${BUILDOS}
        ${HOME}/installscripts/InstallAcme.sh ${BUILDOS} ${SYSTEM_FROMEMAIL_ADDRESS} 
fi

if ( [ "`/bin/grep -r ${SYSTEM_FROMEMAIL_ADDRESS} ~/.acme.sh`" = "" ] )
then
        ~/.acme.sh/acme.sh --register-account -m "${SYSTEM_FROMEMAIL_ADDRESS}" 
fi

~/.acme.sh/acme.sh --set-default-ca --server "${server}"

~/.acme.sh/acme.sh --remove --domain ${WEBSITE_URL} 
~/.acme.sh/acme.sh --update-account -m "${SYSTEM_FROMEMAIL_ADDRESS}" --force

if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
then
        account_id="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':::' '{print $1}'`"
        api_token="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':::' '{print $2}'`"

        export CF_Account_ID="${account_id}"
        export CF_Token="${api_token}"
        ~/.acme.sh/acme.sh --issue --dns dns_cf -d "${WEBSITE_URL}" --server ${server} --standalone
fi

if ( [ "${DNS_CHOICE}" = "digitalocean" ] )
then
        if ( [ -f ~/.acme.sh/dnsapi/dns_dgon.sh ] )
        then
                /bin/cp  ${HOME}/providerscripts/security/ssl/acme/acme-overrides/digitalocean.sh ~/.acme.sh/dnsapi/dns_dgon.sh 
        fi
        ~/.acme.sh/acme.sh --issue --dns dns_dgon -d "${WEBSITE_URL}" --server ${server} --standalone
fi

if ( [ "${DNS_CHOICE}" = "exoscale" ] )
then
        if ( [ -f ~/.acme.sh/dnsapi/dns_exoscale.sh ] )
        then
                /bin/cp  ${HOME}/providerscripts/security/ssl/acme/acme-overrides/exoscale.sh ~/.acme.sh/dnsapi/dns_exoscale.sh
        fi

        ~/.acme.sh/acme.sh --issue --dns dns_exoscale -d "${WEBSITE_URL}" --server ${server} --standalone
fi

if ( [ "${DNS_CHOICE}" = "linode" ] )
then
        if ( [ -f ~/.acme.sh/dnsapi/dns_linode_v4.sh ] )
        then
                /bin/cp  ${HOME}/providerscripts/security/ssl/acme/acme-overrides/linode.sh ~/.acme.sh/dnsapi/dns_linode_v4.sh
        fi
        ~/.acme.sh/acme.sh --issue --dns dns_linode_v4 -d "${WEBSITE_URL}" --server ${server} --standalone
fi

if ( [ "${DNS_CHOICE}" = "vultr" ] )
then
        if ( [ -f ~/.acme.sh/dnsapi/dns_vultr.sh ] )
        then
                /bin/cp  ${HOME}/providerscripts/security/ssl/acme/acme-overrides/vultr.sh ~/.acme.sh/dnsapi/dns_vultr.sh
        fi
        ~/.acme.sh/acme.sh --issue --dns dns_vultr -d "${WEBSITE_URL}" --server ${server} --standalone 
fi

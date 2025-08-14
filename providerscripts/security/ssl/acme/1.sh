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
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/cut -d'.' -f2-`"
WEBSITE_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
PRODUCTION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PRODUCTION'`"
DEVELOPMENT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DEVELOPMENT'`"
SSL_GENERATION_METHOD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSLGENERATIONMETHOD'`"
SSL_GENERATION_SERVICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSLGENERATIONSERVICE'`"

if ( [ "${SSL_GENERATION_SERVICE}" = "LETSENCRYPT" ] )
then
        if ( [ "${SSL_LIVE_CERT}" = "1" ] )
        then
                server="letsencrypt"
        elif ( [ "${SSL_LIVE_CERT}" = "0" ] )
        then
                server="letsencrypt_test"
        fi
elif ( [ "${SSL_GENERATION_SERVICE}" = "ZEROSSL" ] )
then
        server="zerossl"
fi

if ( [ "${SYSTEM_FROMEMAIL_ADDRESS}" = "" ] )
then
        SYSTEM_FROMEMAIL_ADDRESS="${DNS_USERNAME}"
fi

if ( [ ! -f ~/.acme.sh/acme.sh ] )
then
        ${BUILD_HOME}/installscripts/InstallSocat.sh ${BUILDOS}
        ${BUILD_HOME}/installscripts/InstallAcme.sh ${BUILDOS} ${SYSTEM_FROMEMAIL_ADDRESS} #"https://acme-v02.api.letsencrypt.org/directory "
fi

if ( [ "`/bin/grep -r ${SYSTEM_FROMEMAIL_ADDRESS} ~/.acme.sh`" = "" ] )
then
        ~/.acme.sh/acme.sh --register-account -m "${SYSTEM_FROMEMAIL_ADDRESS}" 
fi

~/.acme.sh/acme.sh --set-default-ca --server "${server}"

~/.acme.sh/acme.sh --remove --domain ${WEBSITE_URL} 

if ( [ -d ~/.acme.sh/${WEBSITE_URL}_ecc ] )
then
        /bin/rm -r ~/.acme.sh/${WEBSITE_URL}_ecc
fi

~/.acme.sh/acme.sh --update-account -m "${SYSTEM_FROMEMAIL_ADDRESS}" --force

if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
then
        #Need to update doco to explain they need to get cloudflare token and cloudflare account_id NOT cloudflare GLOBAL API key
        #https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_cf
        #DNS_SECURITY_KEY="XXXXX:YYYYYY" - like exoscale

        account_id="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':::' '{print $1}'`"
        api_token="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':::' '{print $2}'`"
        
        export CF_Account_ID="${account_id}"
        export CF_Token="${api_token}"
        ~/.acme.sh/acme.sh --issue --dns dns_cf -d "${WEBSITE_URL}" --server ${server} 
fi

if ( [ "${DNS_CHOICE}" = "digitalocean" ] )
then
        export DO_API_KEY="${DNS_SECURITY_KEY}" 
        ~/.acme.sh/acme.sh --issue --dns dns_dgon -d "${WEBSITE_URL}" --server ${server}
fi

if ( [ "${DNS_CHOICE}" = "exoscale" ] )
then
        export EXOSCALE_API_KEY="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':' '{print $1}'`"
        export EXOSCALE_API_SECRET="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':' '{print $2}'`"
        ~/.acme.sh/acme.sh --issue --dns dns_exoscale -d "${WEBSITE_URL}" --server ${server} 
fi

if ( [ "${DNS_CHOICE}" = "linode" ] )
then
        export LINODE_V4_API_KEY="${DNS_SECURITY_KEY}" 
        ~/.acme.sh/acme.sh --issue --dns dns_linode_v4 -d "${WEBSITE_URL}" --server ${server} 
fi

if ( [ "${DNS_CHOICE}" = "vultr" ] )
then
        export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/TOKEN`"
        ~/.acme.sh/acme.sh --issue --dns dns_vultr -d "${WEBSITE_URL}" --server ${server} 
fi

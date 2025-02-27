#!/bin/sh
#######################################################################################
# Description: If needs be, this script will install the necessary toolkit and generate
# a SSL certificate.
# Date: 16-11=16
# Author: Peter Winter
######################################################################################
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
#################################################################################
#################################################################################
#set -x

BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
SSL_LIVE_CERT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSLLIVECERT'`"
DNS_USERNAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DNSUSERNAME'`"
DNS_SECURITY_KEY="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DNSSECURITYKEY'`"
DNS_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
PRODUCTION="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'PRODUCTION'`"
DEVELOPMENT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DEVELOPMENT'`"

#Install GO for use installing the new cert
cd ${HOME}

if ( [ ! -d /usr/local/go ] )
then
   ${HOME}/installscripts/InstallGo.sh ${BUILDOS}
fi

export GOROOT=/usr/local/go
export GOPATH=$HOME
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

if ( [ ! -f /usr/bin/lego ] )
then
        ${HOME}/installscripts/InstallLego.sh ${BUILDOS}
fi

if ( [ "`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSLGENERATIONMETHOD'`" = "AUTOMATIC" ] )
then

   DOMAIN_URL="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/awk -F'.' '{$1="";print}' | /bin/sed 's/^ //' | /bin/sed 's/ /./g'`"

   if ( [ "`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSL_GENERATION_SERVICE'`" = "LETSENCRYPT" ] )
   then
      if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
      then
         if ( [ "${SSL_LIVE_CERT}" = "1" ] )
         then
            /bin/echo ${SERVER_USER_PASSWORD}  | /usr/bin/sudo -S -E CLOUDFLARE_EMAIL="${DNS_USERNAME}" CLOUDFLARE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --accept-tos run
         else
           /bin/echo ${SERVER_USER_PASSWORD}  | /usr/bin/sudo -S -E CLOUDFLARE_EMAIL="${DNS_USERNAME}" CLOUDFLARE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}"  --server=https://acme-staging-v02.api.letsencrypt.org/directory --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --accept-tos run
         fi

         if ( [ "$?" = "0" ] )
         then
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATED" "Successfully generated a new SSL Certificate" "INFO"
         else
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATION FAILED" "Failed to generate a new SSL certificate, you might want to look into why..." "ERROR"
         fi
      fi
           
      if ( [ "${DNS_CHOICE}" = "digitalocean" ]  )
      then
           #For production
           if ( [ "${SSL_LIVE_CERT}" = "1" ] )
           then
                /bin/echo ${SERVER_USER_PASSWORD}  | /usr/bin/sudo -S -E DO_AUTH_TOKEN="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run
           else
                 #For Development/Staging (will give insecure message in browser but isnt subject to issuance limits)
                /bin/echo ${SERVER_USER_PASSWORD}  | /usr/bin/sudo -S -E DO_AUTH_TOKEN="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}"  --server=https://acme-staging-v02.api.letsencrypt.org/directory --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run
           fi
                         
           if ( [ "$?" = "0" ] )
           then
                 ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATED" "Successfully generated a new SSL Certificate" "INFO"
           else
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATION FAILED" "Failed to generate a new SSL certificate, you might want to look into why..." "ERROR"
           fi
      fi

      if ( [ "${DNS_CHOICE}" = "exoscale" ] )
      then
           DNS_USERNAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DNSUSERNAME'`"
           DNS_SECURITY_KEYS="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DNSSECURITYKEY' stripped`"
           EXOSCALE_API_KEY="`/bin/echo ${DNS_SECURITY_KEYS} | /usr/bin/awk '{print $1}'`"
           EXOSCALE_API_SECRET="`/bin/echo ${DNS_SECURITY_KEYS} | /usr/bin/awk '{print $2}'`"

           #For production
           if ( [ "${SSL_LIVE_CERT}" = "1" ] )
           then
                /bin/echo ${SERVER_USER_PASSWORD}  | /usr/bin/sudo -S -E EXOSCALE_API_KEY=${EXOSCALE_API_KEY} EXOSCALE_API_SECRET=${EXOSCALE_API_SECRET} /usr/bin/lego --email ${DNS_USERNAME} --dns exoscale --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run
           else
                #For Development/Staging (will give insecure message in browser but isnt subject to issuance limits)
                /bin/echo ${SERVER_USER_PASSWORD}  | /usr/bin/sudo -S -E EXOSCALE_API_KEY=${EXOSCALE_API_KEY} EXOSCALE_API_SECRET=${EXOSCALE_API_SECRET} /usr/bin/lego --email ${DNS_USERNAME} --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns exoscale --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run
           fi

           if ( [ "$?" = "0" ] )
           then
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATED" "Successfully generated a new SSL Certificate" "INFO"
           else
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATION FAILED" "Failed to generate a new SSL certificate, you might want to look into why..." "ERROR"
           fi
      fi

      if ( [ "${DNS_CHOICE}" = "linode" ]  )
      then
           #For production
           if ( [ "${SSL_LIVE_CERT}" = "1" ] )
           then
                command="LINODE_TOKEN=${DNS_SECRITY_KEY} /usr/bin/lego --email ${DNS_USERNAME} --dns ${DNS_CHOICE}v4 --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
           else
                #For Development/Staging (will give insecure message in browser but isnt subject to issuance limits)
                command="LINODE_TOKEN=${DNS_SECRITY_KEY}  /usr/bin/lego --email ${DNS_USERNAME} --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns ${DNS_CHOICE}v4 --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
           fi

           if ( [ "$?" = "0" ] )
           then
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATED" "Successfully generated a new SSL Certificate" "INFO"
           else
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATION FAILED" "Failed to generate a new SSL certificate, you might want to look into why..." "ERROR"
           fi
      fi

      if ( [ "${DNS_CHOICE}" = "vultr" ]  )
      then
           #For production
           if ( [ "${SSL_LIVE_CERT}" = "1" ] )
           then
                command="VULTR_API_KEY=${DNS_SECRITY_KEY}  /usr/bin/lego --email ${DNS_USERNAME} --dns ${DNS_CHOICE} --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
           else
                #For Development/Staging (will give insecure message in browser but isnt subject to issuance limits)
                command="VULTR_API_KEY=${DNS_SECRITY_KEY}  /usr/bin/lego --email ${DNS_USERNAME} --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns ${DNS_CHOICE} --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
           fi

           if ( [ "$?" = "0" ] )
           then
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATED" "Successfully generated a new SSL Certificate" "INFO"
           else
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATION FAILED" "Failed to generate a new SSL certificate, you might want to look into why..." "ERROR"
           fi
      fi
   fi
fi

if ( [ "`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSLGENERATIONMETHOD'`" = "MANUAL" ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERTIFICATE REQUIRED ON WEBSERVER(S)" "Your SSL issuance method is set to manual, you need to replace your SSL certificate(s) on your webserver(s) as they are about to expire" "ERROR"
fi

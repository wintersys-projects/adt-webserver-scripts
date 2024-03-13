#!/bin/sh
################################################################################
# Author: Peter Winter
# Date  : 07/07/2016
# Description: This script tests the current SSL certificate. If it is out of date
# or approaching it's expiry date, a new certificate is generated and replaces it.
# This check is also done on the build client, where a copy of the SSL certificate
# but is necessary here, it is run daily from cron, in case the infrastructure is
# left running for extended periods meaning there is no new builds and therefore no
# opportunity to check for the validity of the certificate.
##################################################################################
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
###################################################################################
###################################################################################
#set -x

exec >>${HOME}/logs/SSL_CERT_INSTALLATION.log
exec 2>&1

#Setup configuration parameters
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
DNS_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DNSUSERNAME'`"
DNS_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DNSCHOICE'`"
DNS_SECURITY_KEY="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DNSSECURITYKEY'`"
SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"

#Get the values we need from our current certificate
if ( [ -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ] && [ -f ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ] )
then
    if ( [ "`/usr/bin/openssl x509 -checkend 604800 -noout -in ${HOME}/ssl/live/*/privkey.pem | /bin/grep 'Certificate will expire'`" != "" ] )
    then
        cd ${HOME}
        /bin/echo "Invalid SSL Certificate found during daily audit - `/usr/bin/date` generating a new certificate"
        ${HOME}/providerscripts/email/SendEmail.sh "INVALID SSL CERTIFICATE DETECTED" "Invalid SSL Certificate found  during daily audit - generating a new certificate" "ERROR"
        . ${HOME}/security/ObtainSSLCertificate.sh
    else
        #If we are here, then the certificate we had was valid and we didn't need to generate a new one this time around
        /bin/echo "Valid SSL Cerificate found during daily audit- `/usr/bin/date`"
    fi
fi

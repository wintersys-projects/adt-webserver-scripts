#!/bin/sh
################################################################################
# Author: Peter Winter
# Date  : 07/07/2016
# Description: This script tests the current SSL certificate. If it is out of date
# or approaching its expiry date, a new certificate is generated and replaces it.
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

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
DNS_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
SSL_GENERATION_SERVICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSLGENERATIONSERVICE'`"

if ( [ "${SSL_GENERATION_SERVICE}" = "LETSENCRYPT" ] )
then
        ssl_service="lets"
elif ( [ "${SSL_GENERATION_SERVICE}" = "ZEROSSL" ] )
then
        ssl_service="zero"
fi

ssl_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${DNS_CHOICE}-${ssl_service}-ssl"

if ( [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${ssl_bucket}/fullchain.pem`" != "" ] && [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${ssl_bucket}/privkey.pem`" != "" ] )
then
        ${HOME}/providerscripts/datastore/GetFromDatastore.sh ${ssl_bucket}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.new
        ${HOME}/providerscripts/datastore/GetFromDatastore.sh ${ssl_bucket}/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.new
fi

if ( [ "`/usr/bin/diff ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.new ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem`" != "" ] && [ "`/usr/bin/diff ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.new ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem`" != "" ] )
then
        /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.$$
        /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.$$
        /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.new ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
        /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.new ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
        /bin/chown www-data:www-data ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
        /bin/chown www-data:www-data ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
        /bin/chmod 640 ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
        /bin/chmod 640 ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
fi






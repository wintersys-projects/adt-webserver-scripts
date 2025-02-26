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

WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh ssl/fullchain.pem`" -lt "600" ] && [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh ssl/privkey.pem`" -lt "600" ] )
then
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.new
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.new

        if ( [ -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.new ] && [ -f ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.new ] )
        then
                /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem-`/usr/bin/date | /bin/sed 's/ //g'`
                /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem-`/usr/bin/date | /bin/sed 's/ //g'`
                /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.new ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
                /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.new ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
        fi
else
        if ( [ -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ] && [ -f ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ] )
        then
                if ( [ "`/usr/bin/openssl x509 -checkend 604800 -noout -in ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem | /bin/grep 'Certificate will expire'`" != "" ] || [ "`/usr/bin/openssl x509 -checkend 604800 -noout -in ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem | /bin/grep 'Certificate will expire'`" != "" ] )
                then
                        ${HOME}/security/ObtainSSLCertificate.sh
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ssl/fullchain.pem no
                        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ssl/privkey.pem no
                fi
        else
                ${HOME}/security/ObtainSSLCertificate.sh
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ssl/fullchain.pem no
                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ssl/privkey.pem no
        fi

fi

#!/bin/sh
################################################################################
# Author: Peter Winter
# Date  : 07/07/2016
# Description: When an SSL certificate has expired and renewed this script looks for
# the new certificate in the datastore and updates the webserver with the new
# certificate. NOTE: certificate renewal is actioned by a cronjob running on your 
# build machine that is commented out by default and needs to be actively commented
# in if you intend to run your servers long term such that certificates are likely
# to expire in due course.
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

if ( [ "`${HOME}/providerscripts/datastore/operations/ListFromDatastore.sh "ssl" "fullchain.pem"`" != "" ] && [ "`${HOME}/providerscripts/datastore/operations/ListFromDatastore.sh "ssl" "privkey.pem"`" != "" ] )
then
        if ( [ ! -d ${HOME}/ssl/live/${WEBSITE_URL}/new ] )
        then
                /bin/mkdir -p ${HOME}/ssl/live/${WEBSITE_URL}/new 
        fi
        ${HOME}/providerscripts/datastore/operations/GetFromDatastore.sh "ssl" "fullchain.pem" "${HOME}/ssl/live/${WEBSITE_URL}/new"
        ${HOME}/providerscripts/datastore/operations/GetFromDatastore.sh "ssl" "privkey.pem" "${HOME}/ssl/live/${WEBSITE_URL}/new"
fi

if ( [ -f ${HOME}/ssl/live/${WEBSITE_URL}/new/fullchain.pem ] && [ -f ${HOME}/ssl/live/${WEBSITE_URL}/new/privkey.pem ] )
then
        if ( [ "`/usr/bin/diff ${HOME}/ssl/live/${WEBSITE_URL}/new/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem`" != "" ] && [ "`/usr/bin/diff ${HOME}/ssl/live/${WEBSITE_URL}/new/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem`" != "" ] )
        then
                if ( [ -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ] &&  [ ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ] )
                then
                        /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.$$
                        /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.$$
                fi
                /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/new/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
                /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/new/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
                /bin/chown www-data:www-data ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
                /bin/chown www-data:www-data ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
                /bin/chmod 640 ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
                /bin/chmod 640 ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
                ${HOME}/providerscripts/webserver/ReloadWebserver.sh
        fi
fi






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
SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SSL_GENERATION_METHOD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSLGENERATIONMETHOD'`"
SSL_GENERATION_SERVICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSLGENERATIONSERVICE'`"

if ( [ "${SSL_GENERATION_SERVICE}" = "LETSENCRYPT" ] )
then
        ssl_service="lets"
        if ( [ "`/bin/grep "^SSLCERTCLIENT:lego" ${HOME}/runtime/buildstyles.dat`" = "" ] )
        then
                ${HOME}/providerscripts/email/SendEmail.sh "INCONSISTENT CONFIGURATION" "Letsencrypt requires the lego acme client it looks like you had something else set so I have forced lego" "ERROR"

                if ( [ "`/bin/grep "^SSLCERTCLIENT:" ${HOME}/runtime/buildstyles.dat`" != "" ] )
                then
                        /bin/sed -i 's/SSLCERTCLIENT:*/SSLCERTCLIENT:lego/g' ${HOME}/runtime/buildstyles.dat
                else
                        /bin/echo "SSLCERTCLIENT:lego" >> ${HOME}/runtime/buildstyles.dat
                fi
        fi
elif ( [ "${SSL_GENERATION_SERVICE}" = "ZEROSSL" ] )
then
        ssl_service="zero"
        if ( [ "`/bin/grep "^SSLCERTCLIENT:acme" ${HOME}/runtime/buildstyles.dat`" = "" ] )
        then
                ${HOME}/providerscripts/email/SendEmail.sh "INCONSISTENT CONFIGURATION" "ZeroSSL requires the acme.sh client it looks like you had something else set so I have forced acme.sh" "ERROR"

                if ( [ "`/bin/grep "^SSLCERTCLIENT:" ${HOME}/runtime/buildstyles.dat`" != "" ] )
                then
                        /bin/sed -i 's/SSLCERTCLIENT:*/SSLCERTCLIENT:acme/g' ${HOME}/runtime/buildstyles.dat
                else
                        /bin/echo "SSLCERTCLIENT:acme" >> ${HOME}/runtime/buildstyles.dat
                fi
        fi
fi

ssl_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${DNS_CHOICE}-${ssl_service}-ssl"

if ( [ ! -d ${HOME}/logs/ssl-installation ] )
then
        /bin/mkdir -p ${HOME}/logs/ssl-installation
fi

exec 1>${HOME}/logs/ssl-installation/ssl-out.log
exec 2>${HOME}/logs/ssl-installation/ssl-err.log

if ( [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${ssl_bucket}/SSL_UPDATING`" != "" ] )
then
        if ( [ "`${HOME}/providerscripts/datastore/AgeOfDatastoreFile.sh ${ssl_bucket}/SSL_UPDATING`" -gt "600" ] )
        then
                ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${ssl_bucket}/SSL_UPDATING
        fi
fi

count="0"
while ( [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${ssl_bucket}/SSL_UPDATING`" != "" ] && [ "${count}" -lt "200" ] )
do
        /bin/sleep 10
        count="`/usr/bin/expr ${count} + 1`"
done

if ( [ "${count}" = "200" ] )
then
        exit
fi

if ( [ ! -d ${HOME}/ssl/live/${WEBSITE_URL} ] )
then
        /bin/mkdir ${HOME}/ssl/live/${WEBSITE_URL} 
fi

issued="0"
if ( ( [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${ssl_bucket}/fullchain.pem`" != "" ] && [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${ssl_bucket}/privkey.pem`" != "" ] ) && ( [ "`${HOME}/providerscripts/datastore/AgeOfDatastoreFile.sh ${ssl_bucket}/fullchain.pem`" -lt "600" ] && [ "`${HOME}/providerscripts/datastore/AgeOfDatastoreFile.sh ${ssl_bucket}/privkey.pem`" -lt "600" ] ) )
then
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.new
        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/${WEBSITE_URL}/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.new

        if ( [ -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.new ] && [ -f ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.new ] )
        then
                /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem.new ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
                /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem.new ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
        fi
else
        if ( [ -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ] && [ -f ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ] )
        then
                /bin/touch ${HOME}/runtime/SSL_UPDATING
                ${HOME}/providerscripts/datastore/PutToDatastore.sh ${HOME}/runtime/SSL_UPDATING ${ssl_bucket}/SSL_UPDATING

                if ( [ "`/usr/bin/openssl x509 -checkend 604800 -noout -in ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem | /bin/grep 'Certificate will expire'`" != "" ] || [ "`/usr/bin/openssl x509 -checkend 604800 -noout -in ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem | /bin/grep 'Certificate will expire'`" != "" ] )
                then
                        if ( [ "${SSL_GENERATION_METHOD}" = "AUTOMATIC" ] )
                        then
                                if ( [ "`/bin/grep "^SSLCERTCLIENT:lego" ${HOME}/runtime/buildstyles.dat`" != "" ] )
                                then
                                        ${HOME}/providerscripts/security/ssl/lego/ObtainSSLCertificate.sh
                                elif ( [ "`/bin/grep "^SSLCERTCLIENT:acme*" ${HOME}/runtime/buildstyles.dat`" != "" ] )
                                then
                                        ${HOME}/providerscripts/security/ssl/acme/ObtainSSLCertificate.sh
                                fi

                                if ( [ -f ${HOME}/.lego/certificates/${WEBSITE_URL}.crt ] && [ -f ${HOME}/.lego/certificates/${WEBSITE_URL}.key ] )
                                then
                                        /bin/mv ${HOME}/.lego/certificates/${WEBSITE_URL}.crt ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
                                        /bin/mv ${HOME}/.lego/certificates/${WEBSITE_URL}.key ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
                                else
                                        ${HOME}/providerscripts/email/SendEmail.sh "FAILED TO OBTAIN SSL CERTIFICATE" "The system has failed to generate an SSL certificate when it needed to" "ERROR"
                                fi

                                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ssl/${WEBSITE_URL}/fullchain.pem no
                                ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ssl/${WEBSITE_URL}/privkey.pem no
                                ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${ssl_bucket}/SSL_UPDATING
                                issued="1"
                        elif ( [ "${SSL_GENERATION_METHOD}" = "MANUAL" ] )
                        then
                                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERTIFICATE REQUIRED" "Notification: Your SSL certificate is set to manual and will need to be updated on your webservers as it will expire soon" "ERROR"
                        fi
                fi
        else
                /bin/touch ${HOME}/runtime/SSL_UPDATING
                ${HOME}/providerscripts/datastore/PutToDatastore.sh ${HOME}/runtime/SSL_UPDATING ${ssl_bucket}/SSL_UPDATING

                if ( [ "`/bin/grep "^SSLCERTCLIENT:lego" ${HOME}/runtime/buildstyles.dat`" != "" ] )
                then
                        ${HOME}/providerscripts/security/ssl/lego/ObtainSSLCertificate.sh
                elif ( [ "`/bin/grep "^SSLCERTCLIENT:acme*" ${HOME}/runtime/buildstyles.dat`" != "" ] )
                then
                        ${HOME}/providerscripts/security/ssl/acme/ObtainSSLCertificate.sh
                fi

                if ( [ -f ${HOME}/.lego/certificates/${WEBSITE_URL}.crt ] && [ -f ${HOME}/.lego/certificates/${WEBSITE_URL}.key ] )
                then
                        /bin/mv ${HOME}/.lego/certificates/${WEBSITE_URL}.crt ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
                        /bin/mv ${HOME}/.lego/certificates/${WEBSITE_URL}.key ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
                else
                        ${HOME}/providerscripts/email/SendEmail.sh "FAILED TO OBTAIN SSL CERTIFICATE" "The system has failed to generate an SSL certificate when it needed to" "ERROR"
                fi

                if ( ( [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${ssl_bucket}/fullchain.pem`" != "" ] && [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${ssl_bucket}/privkey.pem`" != "" ] ) && ( [ "`${HOME}/providerscripts/datastore/AgeOfDatastoreFile.sh ${ssl_bucket}/fullchain.pem`" -gt "600" ] && [ "`${HOME}/providerscripts/datastore/AgeOfDatastoreFile.sh ${ssl_bucket}/privkey.pem`" -gt "600" ] ) )
                then
                        ${HOME}/providerscripts/datastore/PutToDatastore.sh ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${ssl_bucket}/fullchain.pem no
                        ${HOME}/providerscripts/datastore/PutToDatastore.sh ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ${ssl_bucket}/privkey.pem no
                        ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${ssl_bucket}/SSL_UPDATING
                fi
                issued="1"
        fi

        if ( [ "${issued}" = "1" ] )
        then
                /bin/cat ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem > ${HOME}/ssl/live/${WEBSITE_URL}/ssl.pem
                /bin/cp ${HOME}/ssl/live/${WEBSITE_URL}/ssl.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
                /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/ssl.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem


                ssl_bucket_found="0"
                if ( [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${ssl_bucket}/fullchain.pem`" = "" ] )
                then
                        ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${ssl_bucket}/fullchain.pem
                        ssl_bucket_found="1"
                fi
                if ( [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${ssl_bucket}/privkey.pem`" = "" ] )
                then
                        ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${ssl_bucket}/privkey.pem
                        ssl_bucket_found="1"
                fi
                #Make sure that we have an ssl bucket
                if ( [ "${ssl_bucket_found}" = "0" ] )
                then
                        ${HOME}/providerscripts/datastore/MountDatastore.sh ${ssl_bucket} 2>/dev/null
                fi

                ${HOME}/providerscripts/datastore/PutToDatastore.sh ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${ssl_bucket}
                ${HOME}/providerscripts/datastore/PutToDatastore.sh ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ${ssl_bucket}

                ${HOME}/providerscripts/webserver/RestartWebserver.sh
        fi
fi

/bin/chown ${SERVER_USER}:root ${HOME}/ssl/live/${WEBSITE_URL}/*

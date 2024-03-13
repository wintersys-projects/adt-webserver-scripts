#!/bin/sh
#############################################################################
# Description: It is important to remember that there can be 1..n webservers
# running and yet they will all want the same SSL certificate.
# If one webserver detects, 'hey shit, the SSL cert is getting low on it's validity'
# then it will generate a new one. We don't want all the other webservers to go off
# and generate their own certificates when one has already setup a fresh new one, so,
# instead, we copy the fresh certificate to our datastore and then each webserver
# can detect it and make it's own copy of it and then start to use it. It is a rare
# event that a cert will be renewed and we check for it at night, the webserver is
# then reloaded to pick up the new certificate.
# Date: 16/11/2017
# Author: Peter Winter
#############################################################################
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

if ( [ "`/usr/bin/find ${HOME}/runtime/SSLUPDATED -mmin +30`" != "" ] )
then
    /bin/rm ${HOME}/runtime/SSLUPDATED
    
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "SSLUPDATED"`" = "1" ] )
    then
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "SSLUPDATED"
    fi
fi

if ( [ -f ${HOME}/runtime/SSLUPDATED ] )
then
    exit
fi

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
        
if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "ssl/fullchain.pem"`" = "1" ] && [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "ssl/privkey.pem"`" = "1" ] && [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "SSLUPDATED"`" = "1" ] && [ ! -f ${HOME}/runtime/SSLUPDATED ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
    /bin/chown www-data:www-data ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
    /bin/chmod 400 ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
    /bin/chown root:root ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
    ${HOME}/providerscripts/webserver/RestartWebserver.sh
    /bin/touch ${HOME}/runtime/SSLUPDATED
fi

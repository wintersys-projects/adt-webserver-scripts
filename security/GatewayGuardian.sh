#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: Retrieve any existing gateway guardian passwords/credentials
#######################################################################################
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
########################################################################################
########################################################################################
#set -x

BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"

if ( [ ! -d /etc/basicauth ] )
then
    /bin/mkdir /etc/basicauth
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ ! -f ${HOME}/runtime/VIRGINADJUSTED ] )
    then
        ${HOME}/providerscripts/datastore/MoveDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}/htpasswd gatewayguardian-${BUILD_IDENTIFIER}/htpasswd.$$ 
        /bin/touch ${HOME}/runtime/VIRGINADJUSTED
    fi
    ${HOME}/providerscripts/datastore/GetFromDatastore.sh "${DATASTORE_CHOICE}" gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
    /bin/mv htpasswd /etc/basicauth/.htpasswd
    /bin/chown www-data:www-data /etc/basicauth/.htpasswd
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ ! -f ${HOME}/runtime/VIRGINADJUSTED ] )
    then
        ${HOME}/providerscripts/datastore/MoveDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}/htpasswd gatewayguardian-${BUILD_IDENTIFIER}/htpasswd.$$ 
        /bin/touch ${HOME}/runtime/VIRGINADJUSTED
    fi
    ${HOME}/providerscripts/datastore/GetFromDatastore.sh "${DATASTORE_CHOICE}" gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
    /bin/mv htpasswd /etc/basicauth/.htpasswd
    /bin/chown www-data:www-data /etc/basicauth/.htpasswd
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ ! -f ${HOME}/runtime/VIRGINADJUSTED ] )
    then
        ${HOME}/providerscripts/datastore/MoveDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}/htpasswd gatewayguardian-${BUILD_IDENTIFIER}/htpasswd.$$
        /bin/touch ${HOME}/runtime/VIRGINADJUSTED
    fi

    ${HOME}/providerscripts/datastore/GetFromDatastore.sh "${DATASTORE_CHOICE}" gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
    /bin/mv htpasswd /etc/basicauth/.htpasswd
    /bin/chown www-data:www-data /etc/basicauth/.htpasswd
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ ! -f ${HOME}/runtime/VIRGINADJUSTED ] )
    then
        ${HOME}/providerscripts/datastore/MoveDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}/htpasswd gatewayguardian-${BUILD_IDENTIFIER}/htpasswd.$$
        /bin/touch ${HOME}/runtime/VIRGINADJUSTED
    fi    

    ${HOME}/providerscripts/datastore/GetFromDatastore.sh "${DATASTORE_CHOICE}" gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
    /bin/mv htpasswd /etc/basicauth/.htpasswd
    /bin/chown www-data:www-data /etc/basicauth/.htpasswd

fi

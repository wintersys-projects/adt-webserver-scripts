#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/02/2023
# Description: This will add and remove ip addresses from the firewall these ip addresses
# come from the authorisation server when an authorisation server is being used
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
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh AUTHORISATIONSERVER:1`" = "1" ] )
then

    if ( [ ! -d ${HOME}/runtime/authorisationserverips ] )
    then
        /bin/mkdir ${HOME}/runtime/authorisationserverips
    fi

    if ( [ ! -f ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed ] )
    then
        /bin/touch ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed 
    fi

    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh allauthorisationips.dat ${HOME}/runtime/authorisationserverips

    if ( [ -f ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed ] && [ -f ${HOME}/runtime/authorisationserverips/allauthorisationips.dat ] )
    then
        if ( [ "`/bin/cat ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed`" != "" ] )
        then
            for ip in `/bin/cat ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed`
            do
                if ( [ "`/bin/grep ${ip} ${HOME}/runtime/authorisationserverips/allauthorisationips.dat`" = "" ] || [ "`/bin/cat ${HOME}/runtime/authorisationserverips/allauthorisationips.dat`" = "" ] )
                then
                    rule1="`/usr/sbin/ufw status numbered | /bin/grep ${ip} | /bin/grep 443 | /usr/bin/awk -F'[' '{print $2}' | /usr/bin/awk -F']' '{print $1}'`"

                    if ( [ "${rule1}" != "" ] )
                    then
                        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw --force delete ${rule1}
                    fi
                    
                    rule2="`/usr/sbin/ufw status numbered | /bin/grep ${ip} | /bin/grep 80 | /usr/bin/awk -F'[' '{print $2}' | /usr/bin/awk -F']' '{print $1}'`"

                    if ( [ "${rule2}" != "" ] )
                    then
                        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw --force delete ${rule2}
                    fi
                    /bin/sed -i "s/${ip}//g" ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed
                    ${HOME}/providerscripts/webserver/ReloadWebserver.sh
                fi
            done
        fi
    fi

    if ( [ -f ${HOME}/runtime/authorisationserverips/allauthorisationips.dat ] && [ ! -f ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed ] )
    then
        for ip in `/bin/cat ${HOME}/runtime/authorisationserverips/allauthorisationips.dat`
        do
            /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port 80
           /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port 443
       done
       if ( [ "`/bin/grep ${ip} ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed`" = "" ] )
       then 
           /bin/echo ${ip} >> ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed
       fi
   elif ( [ -f ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed ] )
   then
        for ip in `/bin/cat ${HOME}/runtime/authorisationserverips/allauthorisationips.dat`
        do
            if ( [ "`/bin/grep ${ip} ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed`" = "" ] )
            then
                /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port 80
                /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port 443
                /bin/echo ${ip} >> ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed
                ${HOME}/providerscripts/webserver/ReloadWebserver.sh

            fi
        done
   fi
   /bin/sed -i "/^$/d" ${HOME}/runtime/authorisationserverips/authorisationips.dat.processed
fi

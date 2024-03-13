
#!/bin/sh
###################################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This is used as part of the AUTOSCALE_FROM_BACKUP process. When this is set, 
# the first webserver to be built makes a backup of its entire state here and this backup
# is stored in the datastore and can then be restored to a new machine image as part of the 
# autoscaling process
###################################################################################################
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

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh AUTOSCALED:1`" != "1" ] )
then
    while ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverbackup/backup.tgz`" = "" ] )
    do
         if ( [ ! -d /extractionmarker ] )
         then
            /bin/mkdir /extractionmarker
         fi
         
         /bin/touch /extractionmarker/extractedsuccessfully

        if ( [ ! -d ${HOME}/runtime/webserverbackup ] )
        then
            /bin/mkdir ${HOME}/runtime/webserverbackup
        fi
         
        count="0"
         /usr/bin/tar --ignore-failed-read -vcpzf ${HOME}/runtime/webserverbackup/backup.tgz --exclude='backup.tgz' --exclude='dev/*' --exclude='proc/*' --exclude='sys/*' --exclude='tmp/*' --exclude='run/*' --exclude='mnt/*' --exclude='media/*'  --exclude='lost+found/*' --exclude='etc/network/*' --exclude='var/tmp/*' --exclude='var/run/*' --exclude='var/lock/*' --exclude='usr/portage/*' --exclude='usr/src/*' --exclude='var/www/html/*' --exclude='swapfile' /

         while ( ( [ ! -f ${HOME}/runtime/webserverbackup/backup.tgz ] || [ "`/bin/tar tvfz ${HOME}/runtime/webserverbackup/backup.tgz | /bin/grep 'extractedsuccessfully'`" = "" ] ) && [ "${count}" -lt "3" ] )
         do
             count="`/usr/bin/expr ${count} + 1`"
             /usr/bin/tar --ignore-failed-read -vcpzf ${HOME}/runtime/webserverbackup/backup.tgz --exclude='backup.tgz' --exclude='dev/*' --exclude='proc/*' --exclude='sys/*' --exclude='tmp/*' --exclude='run/*' --exclude='mnt/*' --exclude='media/*'  --exclude='lost+found/*' --exclude='etc/network/*' --exclude='var/tmp/*' --exclude='var/run/*' --exclude='var/lock/*' --exclude='usr/portage/*' --exclude='usr/src/*' --exclude='var/www/html/*' --exclude='swapfile' /
         done

         if ( [ "${count}" = "3" ] )
         then
              ${HOME}/providerscripts/email/SendEmail.sh "HAD TROUBLE GENERATING A BACKUP" "Couldn't generate a backup for use in the Build From Backup technique" "ERROR"
         else
             if ( [ -f ${HOME}/runtime/webserverbackup/backup.tgz ] )
             then
                 /usr/bin/sha512sum ${HOME}/runtime/webserverbackup/backup.tgz > ${HOME}/runtime/webserverbackup/checksum.dat
                 ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/webserverbackup/backup.tgz webserverbackup/backup.tgz
                 ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/webserverbackup/checksum.dat webserverbackup/checksum.dat
             fi
         fi  
    done
    /bin/touch ${HOME}/runtime/MONITOR_FOR_OVERLOAD
fi

#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: When we find that there are updates to the webroot of our current
# webroot (additions or deletions) archives of those additions and deletions are written
# to the datastore which other machines in our webserver fleet can apply to their own
# webroots keeping them up to date with us
#####################################################################################
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
####################################################################################
####################################################################################
#set -x

exclude_list=`${HOME}/application/configuration/GetApplicationConfigFilename.sh`
machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "0" ] )
then
        exclude_list="${exclude_list} `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`"
fi

exclude_command=""
if ( [ "${exclude_list}" != "" ] )
then
        /bin/echo "${exclude_list}" | /bin/tr ' ' '\n' | /bin/sed -e 's;^/;;' -e 's;^;/;' > ${HOME}/runtime/webroot_sync/outgoing/exclusion_list.dat
        exclude_command="--exclude-from ${HOME}/runtime/webroot_sync/outgoing/exclusion_list.dat"
fi

#if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
#then
#        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
#        do
#                exclude_list="${exclude_list}$|${dir}"
#        done
#        exclude_list="`/bin/echo ${exclude_list} | /bin/sed 's/|$//g'`"
#fi

#exclude_command=""
#if ( [ "${exclude_list}" != "" ] )
#then
#        /bin/echo "${exclude_list}" | /bin/tr ' ' '\n' | /bin/sed 's;^;/;' > ${HOME}/runtime/webroot_sync/outgoing/exclusion_list.dat
#        exclude_command="--exclude-from ${HOME}/runtime/webroot_sync/outgoing/exclusion_list.dat"
#fi

first_run="0"
if ( [ ! -d /var/www/html1 ] )
then
        first_run="1"
fi

additions_command='cd /var/www/html ; /usr/bin/rsync -ri --dry-run --ignore-existing '${exclude_command}' /var/www/html/ /var/www/html1/ | /usr/bin/cut -d" " -f2 | /bin/sed -e "s;^;\./;g" -e "/.*\/$/d" | /usr/bin/cpio -pdmvu /var/www/html1 2>&1 | /bin/grep "^/var" | /bin/sed "s;/var/www/html1/;;g" | /usr/bin/tr " " "\\n"'
modifieds_command='cd /var/www/html ; /usr/bin/rsync -ri --dry-run --checksum '${exclude_command}' /var/www/html/ /var/www/html1/ | /usr/bin/cut -d" " -f2 | /bin/sed -e "s;^;\./;g" -e  "/.*\/$/d" | /usr/bin/cpio -pdmvu /var/www/html1 2>&1 | /bin/grep "^/var" | /bin/sed "s;/var/www/html1/;;g" | /usr/bin/tr " " "\\n"'
additions=""
additions=`eval ${additions_command}`
modifieds=`eval ${modifieds_command}`
additions="${additions} ${modifieds}"

if ( [ "${first_run}" = "1" ] )
then
        exit
fi

/bin/touch ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.log

for file in ${additions}
do
        /bin/echo "/var/www/html/${file}" | /bin/sed 's:/\./:/:g' >> ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.log
        /bin/echo "/var/www/html1/${file}" | /bin/sed 's:/\./:/:g' >> ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.log
done 

if ( [ -s ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.log ] )
then
        /usr/bin/tar cfzp ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar.gz -T ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.log  --same-owner --same-permissions
fi

/bin/rm ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.log

#deletes_command='/usr/bin/rsync --dry-run -vr /var/www/html1/ /var/www/html 2>&1 | /bin/sed "/^$/d" | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /usr/bin/tr " " "\\n" '${exclude_command}''
deletes_command='/usr/bin/rsync --dry-run -vr '${exclude_command}' /var/www/html1/ /var/www/html 2>&1 | /bin/sed -e "/^$/d" -e  "/.*\/$/d" | /usr/bin/tail -n +2 | /usr/bin/head -n -2 | /usr/bin/tr " " "\\n" '
deletes=`eval ${deletes_command}`

for file in ${deletes}
do
        if ( [ -f /var/www/html1/${file} ] )
        then
                /bin/echo "/var/www/html/${file}"  >> ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log
                /bin/echo "/var/www/html1/${file}" >> ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log
                /bin/rm /var/www/html1/${file}
        fi
done

/usr/bin/find /var/www/html -type d -empty -delete
/usr/bin/find /var/www/html1 -type d -empty -delete

if ( [ "${MULTI_REGION}" != "1" ] )
then
        rnd="`/usr/bin/shuf -i1-10000 -n1`"
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar.gz ] )
        then
                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar.gz webrootsync/additions "no"
                /bin/mv ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar.gz ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.${rnd}.tar.gz
                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.${rnd}.tar.gz webrootsync/historical/additions "no"
        fi
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log ] )
        then
                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log webrootsync/deletions "no"
                /bin/mv ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.${rnd}.log
                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.${rnd}.log webrootsync/historical/deletions "no"
        fi
else
        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
        rnd="`/usr/bin/shuf -i1-10000 -n1`"
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar.gz ] )
        then
                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar.gz ${multi_region_bucket}/webrootsync/additions "no"
                /bin/mv ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.tar.gz ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.${rnd}.tar.gz
                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh ${HOME}/runtime/webroot_sync/outgoing/additions/additions.${machine_ip}.$$.${rnd}.tar.gz ${multi_region_bucket}/webrootsync/historical/additions "no"
        fi
        if ( [ -f ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log ] )
        then
                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log ${multi_region_bucket}/webrootsync/deletions "no"
                /bin/mv ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.log ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.${rnd}.log 
                ${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh  ${HOME}/runtime/webroot_sync/outgoing/deletions/deletions.${machine_ip}.$$.${rnd}.log ${multi_region_bucket}/webrootsync/historical/deletions "no"
        fi
fi

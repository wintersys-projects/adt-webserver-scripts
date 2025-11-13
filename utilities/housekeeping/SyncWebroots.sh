#!/bin/sh





#diff -x '.*' --brief --exclude=images /var/www/html /var/www/html1 | /bin/grep -E "(Only in|differ$)"







######################################################################################################
# Description: This script will synchronise the webroots when "SYNC_WEBROOTS" is set to 1 
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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

if ( [ -f ${HOME}/runtime/BUILD_IN_PROGRESS ] )
then
	exit
fi

${HOME}/utilities/processing/UpdateIPs.sh

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
BUILD_IDENTIFIER="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"

CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

machine_ip="`${HOME}/utilities/processing/GetIP.sh`"

if ( [ ! -d ${HOME}/runtime/webroot_audit ] )
then
	/bin/mkdir ${HOME}/runtime/webroot_audit
fi

for archive in `/usr/bin/find ${HOME}/runtime/webroot_audit -name "*tar.gz"`
do
	/bin/tar xvfz ${archive} -C / --keep-newer-files
	if ( [ "$?" = "0" ] && [ "`/bin/echo ${archive} | /bin/grep alltimers`" = "" ] )
	then
		/bin/rm ${archive}
	fi
done

for deletes_list in `/usr/bin/find ${HOME}/runtime/webroot_audit -name "*deletes*"`
do
	for delete_list in ${deletes_list}
	do
		if ( [ -s ${delete_list} ] )
		then
			for file in `/bin/cat ${delete_list}`
			do
				/bin/rm ${file}
			done
		fi
	done
	/bin/rm ${delete_list}
done

directories_to_miss=""
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
	directories_to_miss="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
fi

if ( [ "${directories_to_miss}" != "" ] )
then
	directories_to_miss="${directories_to_miss} "
	exclude_expressions=""
	for directory in ${directories_to_miss}
	do
		exclude_expressions="${exclude_expressions} -not -path '*${directory}/*'" 
	done
fi

if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat ] )
then
	/bin/mv ${HOME}/runtime/webroot_audit/webroot_file_list.dat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous
fi

find_all_command="/usr/bin/find /var/www/html/ -type f ${exclude_expressions}" 
eval ${find_all_command} > ${HOME}/runtime/webroot_audit/webroot_file_list.dat


if ( [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat ] && [ -f ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous ] )
then
	/usr/bin/diff ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous ${HOME}/runtime/webroot_audit/webroot_file_list.dat | /bin/grep "^<" | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted
	/usr/bin/diff ${HOME}/runtime/webroot_audit/webroot_file_list.dat.previous ${HOME}/runtime/webroot_audit/webroot_file_list.dat | /bin/grep "^>" | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.added
fi

find_new_command="/usr/bin/find /var/www/html -type f  ${exclude_expressions} -newermt '15 seconds ago'" 
eval ${find_new_command} > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified.processing

/bin/grep -vxf  ${HOME}/runtime/webroot_audit/webroot_file_list.dat.added ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified.processing > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified

/bin/rm ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified.processing

/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.added ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified > ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates

if ( [ -s ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates ] )
then
	/usr/bin/tar cfzp ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz -T ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates --owner=www-data --group=www-data
	if ( [ -f ${HOME}/runtime/webroot_audit/webroot_alltimers.${machine_ip}.tar.gz ] )
	then
		/usr/bin/gzip -d ${HOME}/runtime/webroot_audit/webroot_alltimers.${machine_ip}.tar.gz 
	fi
	/usr/bin/tar fpr ${HOME}/runtime/webroot_audit/webroot_alltimers.${machine_ip}.tar -T ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates --owner=www-data --group=www-data
	/usr/bin/gzip ${HOME}/runtime/webroot_audit/webroot_alltimers.${machine_ip}.tar 
fi

if ( [ -s ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates ] || [ -s ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified ] || [ -s ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ] )
then
	/bin/echo "" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
	/bin/echo "========================`/usr/bin/date`=================================" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
	/bin/echo "" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log

	if ( [ -s ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates ] )
	then
		/bin/echo "updated" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
		/bin/echo "--------" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
		/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.updates >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
	fi

	if ( [ -s ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified ] )
	then
		/bin/echo "modified" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
		/bin/echo "--------" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
		/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.modified >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
	fi

	if ( [ -s ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ] )
	then
		/bin/echo "deleted" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
		/bin/echo "--------" >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
		/bin/cat ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted >> ${HOME}/runtime/webroot_audit/webroot_syncing.log
	fi
fi

other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"
initial_sync="0"

for webserver_ip in ${other_webserver_ips}
do
	if ( [ -s ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz ] )
	then
		/usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -P ${SSH_PORT} ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz ${SERVER_USER}@${webserver_ip}:/tmp/webroot_updates.${machine_ip}.tar.gz
		/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv  /tmp/webroot_updates.${machine_ip}.tar.gz ${HOME}/runtime/webroot_audit/webroot_updates.${machine_ip}.tar.gz"
	fi

	if ( [ -s ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ] )
	then
		/usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -P ${SSH_PORT} ${HOME}/runtime/webroot_audit/webroot_file_list.dat.deleted ${SERVER_USER}@${webserver_ip}:/tmp/webroot_deletes.${machine_ip}
		/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -p ${SSH_PORT} ${SERVER_USER}@${webserver_ip} "${CUSTOM_USER_SUDO} /bin/mv  /tmp/webroot_deletes.${machine_ip} ${HOME}/runtime/webroot_audit/webroot_deletes.${machine_ip}"
	fi

	if ( [ ! -f ${HOME}/runtime/INITIAL_WEBROOT_SYNC_DONE ] )
	then
		/usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -P ${SSH_PORT} ${SERVER_USER}@${webserver_ip}:${HOME}/runtime/webroot_audit/webroot_alltimers.${webserver_ip}.tar.gz /tmp/webroot_alltimers.${webserver_ip}.tar.gz
		/bin/mv /tmp/webroot_alltimers.${webserver_ip}.tar.gz ${HOME}/runtime/webroot_audit/webroot_alltimers.${webserver_ip}.tar.gz
		initial_sync="1"
	fi  
done

if ( [ "${initial_sync}" = "1" ] )
then
	/bin/touch ${HOME}/runtime/INITIAL_WEBROOT_SYNC_DONE    
fi




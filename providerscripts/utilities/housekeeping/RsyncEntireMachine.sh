#!/bin/sh

webserver_ip="${1}"
#SERVER_USER="${2}"
#SERVER_USER_PASSWORD="${3}"
#SSH_PORT="${4}"
#ALGORITHM="${5}"
#PERSIST_ASSETS_TO_CLOUD="${6}"
#DIRECTORIES_TO_MOUNT="${7}"
#CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "


#if ( [ "${PERSIST_ASSETS_TO_CLOUD}" = "1" ] )
#then
#  directories_to_miss="`/bin/echo ${DIRECTORIES_TO_MOUNT} | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
#fi

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

directories_to_miss=""
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh PERSISTASSETSTOCLOUD:1`" = "1" ] )
then
        directories_to_miss="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
fi

exclude_command=""

if ( [ "${directories_to_miss}" != "" ] )
then
        for directory in ${directories_to_miss}
        do
                exclude_command="${exclude_command} --exclude=${directory} "
        done
fi
####NEW WAY
#Webservers generate tar archives every 10 minutes and then when a new webserver is being built the tar achive gets topped up with the lastest webroot
#the new webserver then copies the latest tar archive from the webserver of its choice and extracts it to make its own file system

# tar the root directory with the necessary excludes
#tar cvzf - . | /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/XeHPSWgl1jFkNuE7I70X/.ssh/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY -p 1035 XeHPSWgl1jFkNuE7I70X@10.0.1.3 "cat > /tmp/file.tar.gz"
#on remote webserver trigger that a new webserver is building tar the whole machine passing it over ssh to the new machine once it is online and creating a tar archive out of it
#the tar archive can then be extracted by the new webserver


/usr/bin/rsync -azrpu --exclude=/proc --exclude=/mnt --exclude=/tmp --exclude=/dev --exclude=/sys ${exclude_command} -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /usr/bin/rsync " ${SERVER_USER}@${webserver_ip}:/ /
#/usr/bin/rsync -azrpu --exclude=/proc --exclude=/mnt --exclude=/tmp --exclude=/dev --exclude=/sys ${exclude_command} -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv /usr/bin/rsync " ${SERVER_USER}@${webserver_ip}:/ /
#/usr/bin/rsync -azrpu --exclude=/proc --exclude=/mnt --exclude=/tmp --exclude=/dev --exclude=/sys ${exclude_command} -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY" --rsync-path "/usr/bin/sudo -u ${SERVER_USER} /usr/bin/rsync" ${SERVER_USER}@${webserver_ip}:/ /
#/usr/bin/rsync -azrpu --exclude=/proc --exclude=/mnt --exclude=/tmp --exclude=/dev --exclude=/sys ${exclude_command} -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} /usr/bin/sudo -S /usr/bin/rsync" ${SERVER_USER}@${webserver_ip}:/ /

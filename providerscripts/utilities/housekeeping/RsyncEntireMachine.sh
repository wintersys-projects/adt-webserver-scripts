#!/bin/sh

webserver_ip="${1}"
SERVER_USER="${2}"
SERVER_USER_PASSWORD="${3}"
SSH_PORT="${4}"
ALGORITHM="${5}"
PERSIST_ASSETS_TO_CLOUD="${6}"
DIRECTORIES_TO_MOUNT="${7}"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "


if ( [ "${PERSIST_ASSETS_TO_CLOUD}" = "1" ] )
then
  directories_to_miss="`/bin/echo ${DIRECTORIES_TO_MOUNT} | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
fi

exclude_command=""

if ( [ "${directories_to_miss}" != "" ] )
then
        for directory in ${directories_to_miss}
        do
                exclude_command="${exclude_command} --exclude=${directory} "
        done
fi

#/usr/bin/rsync -azrpu --exclude=/proc --exclude=/mnt --exclude=/tmp --exclude=/dev --exclude=/sys ${exclude_command} -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /usr/bin/rsync " ${SERVER_USER}@${webserver_ip}:/ /
#/usr/bin/rsync -azrpu --exclude=/proc --exclude=/mnt --exclude=/tmp --exclude=/dev --exclude=/sys ${exclude_command} -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv /usr/bin/rsync " ${SERVER_USER}@${webserver_ip}:/ /
/usr/bin/rsync -azrpu --exclude=/proc --exclude=/mnt --exclude=/tmp --exclude=/dev --exclude=/sys ${exclude_command} -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY" --rsync-path "/usr/bin/sudo -u ${SERVER_USER} /usr/bin/rsync" ${SERVER_USER}@${webserver_ip}:/ /

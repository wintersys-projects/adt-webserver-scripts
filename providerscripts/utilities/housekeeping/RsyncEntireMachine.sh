

webserver_ip="${1}"
/usr/bin/rsync -azrpu --exclude=/proc --exclude=/mnt --exclude=/tmp --exclude=/dev --exclude=/sys --exclude=/home -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /usr/bin/rsync " / ${SERVER_USER}@${webserver_ip}:/

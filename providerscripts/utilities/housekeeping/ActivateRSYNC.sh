set -x

#Look for files that are 1 minute old or younger if none then don't rsync if there are some then rsync exlude images directory and so on from syncing process

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"
        other_webserver_ips="`/usr/bin/find ${HOME}/runtime/otherwebserverips -type f | /usr/bin/awk -F'/' '{print $NF}'`"

        for webserver_ip in ${other_webserver_ips}
        do
#exclude config file for each application from rsync
                /usr/bin/rsync -azrp -e "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -p ${SSH_PORT}" --rsync-path="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -Sv && /usr/bin/sudo /usr/bin/rsync " /var/www/html/ ${SERVER_USER}@${webserver_ip}:/var/www/html

        done

        #exclude images directory

for node in `/usr/bin/find /var/www/html ! -user www-data -o ! -group www-data`
do
        /bin/chown www-data:www-data ${node}
        if ( [ -d ${node} ] )
        then
                /bin/chmod 755 ${node}
        fi
        if ( [ -f ${node} ] )
        then
                /bin/chmod 644 ${node}
        fi
done



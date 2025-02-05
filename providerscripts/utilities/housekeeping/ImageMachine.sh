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
                exclude_command='"'${exclude_command}'" --exclude="'/var/www/html/${directory}/*'" --exclude="'/var/www/html/${directory}'"'
        done
fi

exclude_command="`/bin/echo ${exclude_command} | /bin/sed 's/\"\"//g'`"

/usr/bin/tar --exclude="/home/X7noRKs3uVgjtxWov9aX/super/*" --exclude="/proc" --exclude="/proc/*" --exclude="/mnt" --exclude="/mnt/*" --exclude="/tmp" --exclude="/tmp/*" --exclude="/dev" --exclude="/dev/*" --exclude="/sys" --exclude="/sys/*" --exclude="/tmp/backup.tar.gz" "${exclude_command}" -zcvp -f /tmp/backup.tar.gz /

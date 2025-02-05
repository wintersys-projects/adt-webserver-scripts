set -x

HOME="`/bin/cat /home/homedir.dat`"

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

/bin/chmod 755 /var/www/html
/bin/chmod 400 /var/www/html/.htaccess

/usr/bin/find ${HOME} -type d -exec chmod 755 {} \;
/usr/bin/find ${HOME} -type f -exec chmod 750 {} \;
/usr/bin/find ${HOME} -type d -exec chown ${SERVER_USER}:root {} \;
/usr/bin/find ${HOME} -type f -exec chown ${SERVER_USER}:root {} \;
/bin/chmod 700 ${HOME}/.ssh
/bin/chmod 644 ${HOME}/.ssh/authorized_keys
/bin/chmod 600 ${HOME}/.ssh/id_*
/bin/chmod 644 ${HOME}/.ssh/id_*pub


#/bin/chmod -R 640 ${HOME}/.ssh/*
#/bin/chown -R ${SERVER_USER}:root ${HOME}/.ssh
#/bin/chmod 640 ${HOME}/super/Super.sh
#/bin/chown ${SERVER_USER}:root ${HOME}/super/Super.sh
#/bin/chmod -R 640 ${HOME}/runtime
#/bin/chown ${SERVER_USER}:root ${HOME}/runtime
#/bin/chmod 644 ${HOME}/runtime/WEBSERVER_READY


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
                exclude_command="${exclude_command} ! -path '/var/www/html/${directory}/* "
        done
fi

for node in `/usr/bin/find /var/www/html ! -user www-data -o ! -group www-data ${exclude_command}`
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

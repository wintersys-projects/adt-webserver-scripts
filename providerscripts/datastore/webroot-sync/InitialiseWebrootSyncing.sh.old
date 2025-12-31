#!/bin/sh

set -x

if ( [ ! -d ${HOME}/runtime/webroot_sync/outgoing/additions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/outgoing/additions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/outgoing/deletions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/outgoing/deletions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming/additions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming/additions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/incoming/deletions ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/incoming/deletions
fi

if ( [ ! -d ${HOME}/runtime/webroot_sync/processed ] )
then
        /bin/mkdir -p ${HOME}/runtime/webroot_sync/processed
fi

command_body=""
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
        do
                command_body="${command_body} --exclude '/"${dir}"' --include '/"${dir}"/'"
        done
fi

config_file="`${HOME}/application/configuration/GetApplicationConfigFilename.sh`"
command_body="${command_body} --exclude '"${config_file}"'" 
/usr/bin/rsync -avp --mkpath --numeric-ids ${command_body} /var/www/html/ /var/www/html1

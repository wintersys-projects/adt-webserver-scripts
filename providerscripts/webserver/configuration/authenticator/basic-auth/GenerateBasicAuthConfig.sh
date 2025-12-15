#!/bin/sh

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURLORIGINAL'`"

if ( [ ! -d ${HOME}/runtime/authenticator ] )
then
        /bin/mkdir -p ${HOME}/runtime/authenticator 
fi

basic_auth_file="${HOME}/runtime/authenticator/basic-auth.dat"

if ( [ -f /tmp/basic-auth.dat ] )
then
        /bin/mv /tmp/basic-auth.dat ${basic_auth_file}.$$
fi

for userdetails in `/bin/cat ${basic_auth_file}.$$`
do
        username="`/bin/echo ${userdetails} | /usr/bin/awk -F':' '{print $1}'`"
        password="`/bin/echo ${userdetails} | /usr/bin/awk -F':' '{print $2}'`"

        if ( [ ! -f ${basic_auth_file} ] )
        then
                /usr/bin/htpasswd -b -c ${basic_auth_file} ${username} ${password}
        else
                /usr/bin/htpasswd -b ${basic_auth_file} ${username} ${password}
        fi
fi

/bin/rm  ${basic_auth_file}.$$


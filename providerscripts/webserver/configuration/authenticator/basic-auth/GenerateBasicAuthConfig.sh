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

for username in `/bin/cat ${basic_auth_file}.$$`
do
        password="p`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-8`p"

        if ( [ ! -f ${basic_auth_file} ] )
        then
                /usr/bin/htpasswd -b -c ${basic_auth_file} ${username} ${password}
        else
                /usr/bin/htpasswd -b ${basic_auth_file} ${username} ${password}
        fi
        message="<!DOCTYPE html> <html> <body> <h1>The basic auth password you requested for ${WEBSITE_URL} is: ${password}. </body> </html>"
	${HOME}/providerscripts/email/SendEmail.sh "Basic Auth password request" "${message}" MANDATORY ${email_address} "HTML" "AUTHENTICATION"
done


#for userdetails in `/bin/cat ${basic_auth_file}.$$`
#do
#        username="`/bin/echo ${userdetails} | /usr/bin/awk -F':' '{print $1}'`"
#        password="`/bin/echo ${userdetails} | /usr/bin/awk -F':' '{print $2}'`"##
#
 #       if ( [ ! -f ${basic_auth_file} ] )
  #      then
   #             /usr/bin/htpasswd -b -c ${basic_auth_file} ${username} ${password}
    #    else
     #           /usr/bin/htpasswd -b ${basic_auth_file} ${username} ${password}
     #   fi
#done

/bin/rm  ${basic_auth_file}.$$


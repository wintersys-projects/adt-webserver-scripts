#!/bin/sh

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURLORIGINAL'`"
USER_EMAIL_DOMAIN="`${HOME}/utilities/config/ExtractConfigValue.sh 'USEREMAILDOMAIN'`"

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
	if ( [ "`/bin/echo ${username} | /bin/grep "${USER_EMAIL_DOMAIN}$"`" != "" ] )
	then
        password="p`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-z0-9' | /usr/bin/cut -b 1-8`p"

        if ( [ ! -f ${basic_auth_file} ] )
        then
                /usr/bin/htpasswd -b -c ${basic_auth_file} ${username} ${password}
        else
                /usr/bin/htpasswd -b ${basic_auth_file} ${username} ${password}
        fi
        message="<!DOCTYPE html> <html> <body> <h1>The basic auth password you requested for ${WEBSITE_URL} is: ${password} </body> </html>"
		${HOME}/providerscripts/email/SendEmail.sh "Basic Auth password request" "${message}" MANDATORY ${username} "HTML" "AUTHENTICATION"

		if ( [ "${MULTI_REGION}" = "1" ] )
		then
			multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
			/bin/cp ${basic_auth_file} ${basic_auth_file}.${ip}
			${HOME}/providerscripts/datastore/PutToDatastore.sh ${basic_auth_file}.${ip} ${multi_region_bucket}/multi-region-basic-auth "yes"
		fi
	fi
done

/bin/rm  ${basic_auth_file}.$$


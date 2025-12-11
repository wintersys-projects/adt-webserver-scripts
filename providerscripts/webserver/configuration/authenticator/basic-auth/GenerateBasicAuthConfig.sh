#!/bin/sh

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURLORIGINAL'`"

if ( [ ! -d ${HOME}/runtime/authenticator ] )
then
	/bin/mkdir -p ${HOME}/runtime/authenticator 
fi

/bin/touch ${HOME}/runtime/authenticator/basic-auth.dat

if ( [ -f /tmp/basic-auth.dat ] )
then
	/bin/mv /tmp/basic-auth.dat ${HOME}/runtime/authenticator/basic-auth.dat.$$
fi

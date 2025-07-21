HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

/bin/rm ${HOME}/runtime/FIREWALL-ACTIVE

if ( [ "`/usr/bin/hostname | /bin/grep '\-rp-'`" != "" ] )
then
	${HOME}/providerscripts/webserver/configuration/reverseproxy/ResetReverseProxyIPs.sh
fi

${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS} &



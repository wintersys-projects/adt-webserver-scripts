HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

/bin/rm ${HOME}/runtime/FIREWALL-ACTIVE



${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS} &




HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

/bin/sed -i "s/XXXXWEBSITEURLXXXX/${WEBSITE_URL}/g"
/bin/sed -i "s/XXXXHOMEXXXX/${HOME}/g"



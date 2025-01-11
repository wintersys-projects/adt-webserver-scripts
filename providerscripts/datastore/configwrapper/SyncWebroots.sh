SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
CUSTOM_USER_SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

${HOME}/providerscripts/utilities/housekeeping/AuditAndUpdateWebrootDeletes.sh
${HOME}/providerscripts/datastore/configwrapper/SyncWebrootToDatastore.sh
${HOME}/providerscripts/datastore/configwrapper/SyncDatastoreToWebroot.sh

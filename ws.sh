#!/bin/sh
######################################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This is the script which builds a webserver
######################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#set -x

#Get ourselves orientated so we know where our home is
USER_HOME="`/usr/bin/awk -F: '{ print $1}' /etc/passwd | /bin/grep "X*X"`"
/bin/echo 'export HOME="/home/'${USER_HOME}'"' >> /home/${USER_HOME}/.bashrc
/bin/chmod 644 /home/${USER_HOME}/.bashrc
/bin/chown ${USER_HOME}:root /home/${USER_HOME}/.bashrc

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

#comment/amend as you desire
if ( [ ! -f /root/.vimrc-adt ] )
then
        /bin/echo "
        set mouse=r
        syntax on
        filetype indent on
        set smartindent
        set fo-=or
        autocmd BufRead,BufWritePre *.sh normal gg=G " > /root/.vimrc-adt

        /bin/echo "alias vim='/usr/bin/vim -u /root/.vimrc-adt'" >> /root/.bashrc
        /bin/echo "alias vi='/usr/bin/vim -u /root/.vimrc-adt'" >> /root/.bashrc
fi

#Set the intialial permissions for the build
/usr/bin/find ${HOME} -not -path '*/\.*' -type d -print0 | xargs -0 chmod 0755 # for directories
/usr/bin/find ${HOME} -not -path '*/\.*' -type f -print0 | xargs -0 chmod 0500 # for files
/bin/chown ${SERVER_USER}:root ${HOME}/.ssh
/bin/chmod 750 ${HOME}/.ssh

/bin/echo 'export HOME=`/bin/cat /home/homedir.dat` && /bin/sh ${1} ${2} ${3} ${4} ${5} ${6}' > /usr/bin/run
/bin/chown ${SERVER_USER}:root /usr/bin/run
/bin/chmod 750 /usr/bin/run
#/bin/echo 'export HOME=`/bin/cat /home/homedir.dat` && /usr/bin/run ${HOME}/application/configuration/ApplicationConfigurationUpdate.sh' > /usr/bin/config
#/bin/chown ${SERVER_USER}:root /usr/bin/config
#/bin/chmod 750 /usr/bin/config
#/bin/echo 'export HOME=`/bin/cat /home/homedir.dat` && /bin/touch ${HOME}/runtime/CONFIG_BEING_CHANGED' > /usr/bin/changing_config
#/bin/chown ${SERVER_USER}:root /usr/bin/changing_config
#/bin/chmod 750 /usr/bin/changing_config
#/bin/echo 'export HOME=`/bin/cat /home/homedir.dat` && /bin/rm ${HOME}/runtime/CONFIG_BEING_CHANGED' > /usr/bin/changed_config
#/bin/chown ${SERVER_USER}:root /usr/bin/changed_config
#/bin/chmod 750 /usr/bin/changed_config

#Set up more operational directories
if ( [ ! -d ${HOME}/.ssh ] )
then
	/bin/mkdir ${HOME}/.ssh
fi

if ( [ ! -d ${HOME}/runtime ] )
then
	/bin/mkdir ${HOME}/runtime
	/bin/chown ${SERVER_USER}:${SERVER_USER} ${HOME}/runtime
	/bin/chmod 755 ${HOME}/runtime
fi

#Setup operational directories if needed
if ( [ ! -d ${HOME}/logs/initialbuild ] )
then
	/bin/mkdir -p ${HOME}/logs/initialbuild
fi

if ( [ ! -d ${HOME}/super ] )
then
	/bin/mkdir ${HOME}/super
fi

/bin/mv ${HOME}/utilities/security/Super.sh ${HOME}/super
/bin/chmod 400 ${HOME}/super/Super.sh

out_file="initialbuild/webserver-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${out_file}
err_file="initialbuild/webserver-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${err_file}

/bin/echo "${0} `/bin/date`: Building a new webserver" 

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
DNS_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DNSCHOICE'`"
SSL_GENERATION_SERVICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'SSLGENERATIONSERVICE'`"
GIT_EMAIL_ADDRESS="`${HOME}/utilities/config/ExtractConfigValue.sh 'GITEMAILADDRESS'`"
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
MACHINE_TYPE="`${HOME}/utilities/config/ExtractConfigValue.sh 'MACHINETYPE'`"
/bin/touch ${HOME}/${MACHINE_TYPE}
GIT_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'GITUSER' | /bin/sed 's/#/ /g'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"

/bin/touch ${HOME}/runtime/BUILD_IN_PROGRESS

#Initialise Git
/usr/bin/git config --global user.name "${GIT_USER}"
/usr/bin/git config --global user.email ${GIT_EMAIL_ADDRESS}
/usr/bin/git config --global init.defaultBranch main
/usr/bin/git config --global pull.rebase false 

if ( [ -f ${HOME}/utilities/software/PushInfrastructureScriptsUpdates.sh ] )
then
	/bin/cp ${HOME}/utilities/software/PushInfrastructureScriptsUpdates.sh /usr/sbin/push
	/bin/chmod 755 /usr/sbin/push
	/bin/chown root:root /usr/sbin/push
fi
if ( [ -f ${HOME}/utilities/software/PushAndSyncInfrastructureScriptsUpdates.sh ] )
then
	/bin/cp ${HOME}/utilities/software/PushAndSyncInfrastructureScriptsUpdates.sh /usr/sbin/push-and-sync
	/bin/chmod 755 /usr/sbin/push-and-sync
	/bin/chown root:root /usr/sbin/push-and-sync
fi
if ( [ -f ${HOME}/utilities/software/SyncInfrastructureScriptsUpdates.sh ] )
then
	/bin/cp ${HOME}/utilities/software/SyncInfrastructureScriptsUpdates.sh /usr/sbin/sync
	/bin/chmod 755 /usr/sbin/sync
	/bin/chown root:root /usr/sbin/sync
fi

/bin/echo "${0} `/bin/date`: Setting up the Firewall" 
${HOME}/security/SetupFirewall.sh

cd ${HOME}

/bin/echo "${0} Installing Datastore tools"
${HOME}/providerscripts/datastore/InitialiseDatastoreConfig.sh

cd ${HOME}

/bin/echo "${0} Installing the bespoke application"
${HOME}/application/InstallApplication.sh

/bin/echo "${0} Setting up application assets datastore"
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" != "1" ] && [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" != "1" ] )
then
	${HOME}/providerscripts/datastore/assets/SetupAssetsStore.sh
fi

/bin/echo "${0} Storing database engine type"
webroot_database_engine="`/bin/cat /var/www/html/dbe.dat`"

if ( [ "${webroot_database_engine}" != "" ] )
then
	DATABASE_INSTALLATION_TYPE="`${HOME}/utilities/config/ExtractConfigValue.sh 'DATABASEINSTALLATIONTYPE'`"

	if ( [ "${webroot_database_engine}" = "Postgres" ] )
	then
		if ( [ "${DATABASE_INSTALLATION_TYPE}" != "Postgres" ] )
		then
			${HOME}/utilities/config/StoreConfigValue.sh "DATABASEINSTALLATIONTYPE" "Postgres"
		fi
	fi

	if ( [ "${webroot_database_engine}" = "MySQL" ] )
	then
		if ( [ "${DATABASE_INSTALLATION_TYPE}" != "MySQL" ] )
		then
			${HOME}/utilities/config/StoreConfigValue.sh "DATABASEINSTALLATIONTYPE" "MySQL"
		fi
	fi
fi

cd ${HOME}

/bin/echo "${0} Determining application type"
${HOME}/application/processing/DetermineApplicationType.sh 

/bin/echo "${0} Initialising crontab"
${HOME}/cron/InitialiseCron.sh

if ( [ "${SSL_GENERATION_SERVICE}" = "LETSENCRYPT" ] )
then
        service_token="lets"
elif ( [ "${SSL_GENERATION_SERVICE}" = "ZEROSSL" ] )
then
        service_token="zero"
fi

ssl_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`"
ssl_bucket="${ssl_bucket}-${DNS_CHOICE}-${service_token}-ssl"

/bin/echo "${0} `/bin/date`: Setting up the SSL certificates and keys" 
if ( [ ! -d ${HOME}/ssl/live/${WEBSITE_URL} ] )
then
	/bin/mkdir -p ${HOME}/ssl/live/${WEBSITE_URL}
fi

/bin/echo "${0} Configuring SSL certificate"
${HOME}/providerscripts/datastore/GetFromDatastore.sh ${ssl_bucket}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}
${HOME}/providerscripts/datastore/GetFromDatastore.sh ${ssl_bucket}/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}
#/bin/cat ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem >> ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
/bin/chown www-data:www-data ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
/bin/chmod 400 ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
/bin/chown root:root ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem

/bin/echo "${0} Sending 'successful build' notification email"
${HOME}/providerscripts/email/SendEmail.sh "A WEBSERVER HAS BEEN SUCCESSFULLY BUILT" "A Webserver has been successfully built and primed as is rebooting ready for use" "INFO"

${HOME}/utilities/processing/UpdateIPs.sh
#${HOME}/application/configuration/SetApplicationConfiguration.sh
${HOME}/utilities/housekeeping/CleanupAfterBuild.sh

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh AUTOSCALED:1`" = "0" ] )
then
	/bin/rm ${HOME}/runtime/BUILD_IN_PROGRESS
fi
/bin/touch ${HOME}/runtime/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK
/usr/bin/touch ${HOME}/runtime/INITIAL_BUILD_WEBSERVER_ONLINE
/usr/bin/touch ${HOME}/runtime/WEBSERVER_READY

/bin/echo "${0} Enforcing Permissions"
${HOME}/utilities/security/EnforcePermissions.sh

/bin/echo "${0} Restarting Webserver"
${HOME}/providerscripts/webserver/RestartWebserver.sh

#/bin/echo "${0} Updating Software"
#${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS} &

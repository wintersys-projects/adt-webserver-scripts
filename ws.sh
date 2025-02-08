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
export HOME="/home/${USER_HOME}" | /usr/bin/tee -a ~/.bashrc

/bin/echo "set mouse=r" > /root/.vimrc

chosen_webserver_ip="${1}"
my_ip="${2}"
my_private_ip="${3}"

#Set the intialial permissions for the build
/usr/bin/find ${HOME} -not -path '*/\.*' -type d -print0 | xargs -0 chmod 0755 # for directories
/usr/bin/find ${HOME} -not -path '*/\.*' -type f -print0 | xargs -0 chmod 0500 # for files
/bin/chown ${SERVER_USER}:root ${HOME}/.ssh
/bin/chmod 750 ${HOME}/.ssh

export HOMEDIR=${HOME}
/bin/echo "${HOMEDIR}" > /home/homedir.dat
/bin/echo 'export HOME=`/bin/cat /home/homedir.dat` && /bin/sh ${1} ${2} ${3} ${4} ${5} ${6}' > /usr/bin/run
/bin/chown ${SERVER_USER}:root /usr/bin/run
/bin/chmod 750 /usr/bin/run
/bin/echo 'export HOME=`/bin/cat /home/homedir.dat` && /usr/bin/run ${HOME}/providerscripts/application/configuration/ApplicationConfigurationUpdate.sh' > /usr/bin/config
/bin/chown ${SERVER_USER}:root /usr/bin/run
/bin/chmod 750 /usr/bin/config

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

#SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

#if ( [ -f ${HOME}/.ssh/webserver_configuration_settings.dat ] )
#then
#	/bin/cp ${HOME}/.ssh/webserver_configuration_settings.dat ${HOME}/runtime/webserver_configuration_settings.dat
# 	/bin/mv ${HOME}/.ssh/webserver_configuration_settings.dat ${HOME}/.ssh/webserver_configuration_settings.dat.original
#  	/bin/chown ${SERVER_USER}:root ${HOME}/.ssh/webserver_configuration_settings.dat.original
#   	/bin/chmod 400 ${HOME}/.ssh/webserver_configuration_settings.dat.original
#	/bin/chown ${SERVER_USER}:root ${HOME}/runtime/webserver_configuration_settings.dat
#	/bin/chmod 640 ${HOME}/runtime/webserver_configuration_settings.dat
#fi

#if ( [ -f ${HOME}/.ssh/buildstyles.dat ] )
#then
#	/bin/cp ${HOME}/.ssh/buildstyles.dat ${HOME}/runtime/buildstyles.dat
# 	/bin/mv ${HOME}/.ssh/buildstyles.dat ${HOME}/.ssh/buildstyles.dat.original
#    	/bin/chown ${SERVER_USER}:root ${HOME}/.ssh/buildstyles.dat.original
#   	/bin/chmod 400 ${HOME}/.ssh/buildstyles.dat.original
#	/bin/chown ${SERVER_USER}:root ${HOME}/runtime/buildstyles.dat
#	/bin/chmod 640 ${HOME}/runtime/buildstyles.dat
#fi





#Setup operational directories if needed
if ( [ ! -d ${HOME}/logs/initialbuild ] )
then
	/bin/mkdir -p ${HOME}/logs/initialbuild
fi

if ( [ ! -d ${HOME}/super ] )
then
	/bin/mkdir ${HOME}/super
fi

/bin/mv ${HOME}/providerscripts/utilities/security/Super.sh ${HOME}/super
/bin/chmod 400 ${HOME}/super/Super.sh

if ( [ -f ${HOME}/InstallGit.sh ] )
then
	/bin/rm ${HOME}/InstallGit.sh
fi

out_file="initialbuild/webserver-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${out_file}
err_file="initialbuild/webserver-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${err_file}


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} `/bin/date`: Building a new webserver" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} `/bin/date`: Setting up the build parameters" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log


#Load the environment into memory for convenience


CLOUDHOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
BUILD_ARCHIVE_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DATASTORECHOICE'`"
WEBSERVER_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"
INFRASTRUCTURE_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPROVIDER'`"
INFRASTRUCTURE_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYUSERNAME'`"
INFRASTRUCTURE_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPASSWORD'`"
INFRASTRUCTURE_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
APPLICATION_IDENTIFIER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONIDENTIFIER'`"

GIT_EMAIL_ADDRESS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'GITEMAILADDRESS'`"
APPLICATION_LANGUAGE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"
SERVER_TIMEZONE_CONTINENT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"
BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"
MACHINE_TYPE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'MACHINETYPE'`"

/bin/touch ${HOME}/${MACHINE_TYPE}

#Non standard environment setup process
GIT_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'GITUSER' | /bin/sed 's/#/ /g'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
#BASELINE_SOURCECODE_REPOSITORY="`/bin/grep -a 'APPLICATIONBASELINESOURCECODEREPOSITORY' ${HOME}/.ssh/webserver_configuration_settings.dat | /usr/bin/cut -d':' -f 2-`"
APPLICATION_BASELINE_SOURCECODE_REPOSITORY="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'APPLICATIONBASELINESOURCECODEREPOSITORY' 'stripped' | /bin/sed 's/ /:/g'`"

#ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
#BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"



#if ( [ ! -f ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ] )
#then#
#	if ( [ -f /etc/ssh/ssh_host_rsa_key ] )
# 	then
#  		/bin/cp /etc/ssh/ssh_host_rsa_key ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}#
#		/bin/chmod 600 ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER#}#
#	fi
# 	if ( [ -f /etc/ssh/ssh_host_rsa_key.pub ] )
# 	then
#  		/bin/cp /etc/ssh/ssh_host_rsa_key.pub ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub#
#		/bin/chmod 600 ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub
#	fi
#fi


/bin/touch ${HOME}/runtime/BUILD_IN_PROGRESS

#Initialise Git
/usr/bin/git config --global user.name "${GIT_USER}"
/usr/bin/git config --global user.email ${GIT_EMAIL_ADDRESS}
/usr/bin/git config --global init.defaultBranch main
/usr/bin/git config --global pull.rebase false 

#. ${HOME}/providerscripts/utilities/housekeeping/InitialiseHostname.sh

#Safety in case kernel panics
/bin/echo "vm.panic_on_oom=1
kernel.panic=10" >> /etc/sysctl.conf

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} `/bin/date`: Updating the software from the repositories" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/rm /var/lib/dpkg/lock
/bin/rm /var/cache/apt/archives/lock

/bin/echo "${0} `/bin/date`: Installing software" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#Install the software packages that we need

if ( [ "`/bin/grep '^#Port' /etc/ssh/sshd_config`" != "" ] || [ "`/bin/grep '^Port' /etc/ssh/sshd_config`" != "" ] )
then
	/bin/sed -i "s/^Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
	/bin/sed -i "s/^#Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
#else
#	/bin/echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Preventing root logins"
/bin/echo "${0} `/bin/date`: Preventing root logins" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#Double down on preventing logins as root. We already tried, but, make absolutely sure because we can't guarantee format of /etc/ssh/sshd_config

#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^PermitRootLogin.*/PermitRootLogin no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^AddressFamily.*/AddressFamily inet/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#AddressFamily.*/AddressFamily inet/g' {} +

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Ensuring SSH connections are long lasting"
/bin/echo "${0} `/bin/date`: Ensuring SSH connections are long lasting" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#Make sure that client connections to sshd are long lasting
if ( [ "`/bin/grep 'ClientAliveInterval 200' /etc/ssh/sshd_config 2>/dev/null`" = "" ] )
then
	/bin/echo "
ClientAliveInterval 200
ClientAliveCountMax 10" >> /etc/ssh/sshd_config
fi

${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh ssh restart



#${HOME}/installscripts/InstallCoreSoftware.sh  

#${HOME}/providerscripts/datastore/EssentialToolsAvailable.sh

${HOME}/security/SetupFirewall.sh

#>&2 /bin/echo "${0} Update.sh"
#${HOME}/installscripts/Update.sh ${BUILDOS}

#>&2 /bin/echo "${0} InstallCurl.sh"
#${HOME}/installscripts/InstallCurl.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallLibioSocketSSL.sh"
#${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallLibnetSSLLeay.sh"
#${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallSendEmail.sh"
#${HOME}/installscripts/InstallSendEmail.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallJQ.sh"
#${HOME}/installscripts/InstallJQ.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallUnzip.sh"
#${HOME}/installscripts/InstallUnzip.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallSSHPass.sh"
#${HOME}/installscripts/InstallSSHPass.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallSysStat.sh"
#${HOME}/installscripts/InstallSysStat.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallFirewall.sh"
#${HOME}/installscripts/InstallFirewall.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallS3FS.sh"
#${HOME}/installscripts/InstallS3FS.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallGoofyFS.sh"
#${HOME}/installscripts/InstallGoofyFS.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallRsync.sh"
#${HOME}/installscripts/InstallRsync.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallCron.sh"
#${HOME}/installscripts/InstallCron.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallGo.sh"
#${HOME}/installscripts/InstallGo.sh ${BUILDOS}

#${HOME}/installscripts/InstallMonitoringGear.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Setting Timezone"
/bin/echo "${0}: Setting timezone" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#Set the time on the machine

#if ( [ "`/usr/bin/timedatectl list-timezones | /bin/grep ${SERVER_TIMEZONE_CONTINENT} | /bin/grep ${SERVER_TIMEZONE_CITY}`" != "" ] )
#then
#	 /usr/bin/timedatectl set-timezone ${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}
#	${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "SERVERTIMEZONECONTINENT" "${SERVER_TIMEZONE_CONTINENT}"
#	${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "SERVERTIMEZONECITY" "${SERVER_TIMEZONE_CITY}"
#	export TZ=":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}"
#fi

cd ${HOME}

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installing Datastore tools"
/bin/echo "${0} Installing Datastore tools" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#. ${HOME}/installscripts/InstallDatastoreTools.sh
. ${HOME}/providerscripts/datastore/InitialiseDatastoreConfig.sh
. ${HOME}/providerscripts/datastore/InitialiseAdditionalDatastoreConfigs.sh



# Install the language engine for whatever language your application is written in
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installing Application Language"
/bin/echo "${0} Installing Application Language: ${APPLICATION_LANGUAGE}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#${HOME}/providerscripts/webserver/InstallApplicationLanguage.sh "${APPLICATION_LANGUAGE}"

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installing Webserver"
/bin/echo "${0} Installing Webserver: ${WEBSERVER_CHOICE} for ${WEBSITE_NAME} at: ${WEBSITE_URL}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "`${HOME}/providerscripts/utilities/processing/GetIP.sh` ${WEBSITE_NAME}WS" >> /etc/hosts
#${HOME}/providerscripts/webserver/InstallWebserver.sh 

cd ${HOME}

#if ( [ ! -d ${HOME}/credentials ] )
#then
#    /bin/mkdir -p ${HOME}/credentials
#    /bin/chmod 700 ${HOME}/credentials
#fi    

#if ( [ ! -f ${HOME}/runtime/CREDENTIALS_PRIMED ] && [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/db_cred"`" = "1" ] )
#then
#    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh credentials/db_cred ${HOME}/credentials/db_cred
#    if ( [ -f ${HOME}/credentials/db_cred ] )
#    then
#        /bin/touch ${HOME}/runtime/CREDENTIALS_PRIMED
#    fi
#fi

#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#>&2 /bin/echo "${0} Disabling password authentication"
#/bin/echo "${0} `/bin/date`: Disabling password authentication" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#/bin/sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
#/bin/sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#>&2 /bin/echo "${0} Changing our preferred SSH port"
#/bin/echo "${0} `/bin/date`: Changing to our preferred SSH port" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#if ( [ -f /etc/systemd/system/ssh.service.d/00-socket.conf ] )
#then#
#	/bin/rm /etc/systemd/system/ssh.service.d/00-socket.conf
#	/bin/systemctl daemon-restart
#fi

#/bin/systemctl disable --now ssh.socket
#/bin/systemctl enable --now ssh.service

#if ( [ ! -d /var/www/html ] )
#then
#	/bin/mkdir -p /var/www/html > /dev/null 2>&1
#fi
#cd /var/www/html
#/bin/rm -r /var/www/html/* > /dev/null 2>&1
#/bin/rm -r /var/www/html/.git > /dev/null 2>&1
#/usr/bin/git init

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installing the custom application"
/bin/echo "${0} Installing the custom application" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] )
#then
#	. ${HOME}/providerscripts/application/InstallApplication.sh
#else
# 	${HOME}/providerscripts/application/InstallApplication.sh &
#fi

####Put this block in a separate script and run it in the background
. ${HOME}/providerscripts/application/InstallApplication.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Applying application specific customisations"
/bin/echo "${0} Applying application specific customisations" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] )
then
	. ${HOME}/providerscripts/application/branding/ApplyApplicationBranding.sh
	. ${HOME}/providerscripts/application/customise/CustomiseApplication.sh
fi
####Put this block in a separate script and run it in the background


#${HOME}/providerscripts/application/customise/AdjustApplicationInstallationByApplication.sh

#The applications record which database engine they are expecting to be running, postgres or mysql. 
#It is possible that someone (someone else) stored a postgres database and is deploying a MySQL by mistake, so, check for that and
#swap engines if we find that there is a mismatch between the engine being used and the engine we expect. 

webroot_database_engine="`/bin/cat /var/www/html/dbe.dat`"

if ( [ "${webroot_database_engine}" != "" ] )
then
	DATABASE_INSTALLATION_TYPE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DATABASEINSTALLATIONTYPE'`"

	if ( [ "${webroot_database_engine}" = "Postgres" ] )
	then
		if ( [ "${DATABASE_INSTALLATION_TYPE}" != "Postgres" ] )
		then
			${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "DATABASEINSTALLATIONTYPE" "Postgres"
		fi
	fi

	if ( [ "${webroot_database_engine}" = "MySQL" ] )
	then
		if ( [ "${DATABASE_INSTALLATION_TYPE}" != "MySQL" ] )
		then
			${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "DATABASEINSTALLATIONTYPE" "MySQL"
		fi
	fi
fi

cd ${HOME}

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Determining application type"
/bin/echo "${0} Find out what type of application we are installing, for example, Joomla, Wordpress, Drupal or Moodle" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
${HOME}/providerscripts/application/processing/DetermineApplicationType.sh > /dev/null 2>&1

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Initialising crontab"
/bin/echo "${0} Initialise the crontab" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

. ${HOME}/cron/InitialiseCron.sh

if ( [ ! -d ${HOME}/ssl/live/${WEBSITE_URL} ] )
then
	/bin/mkdir -p ${HOME}/ssl/live/${WEBSITE_URL}
fi

${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
/bin/chown www-data:www-data ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
/bin/chmod 400 ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
/bin/chown root:root ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem

${HOME}/providerscripts/datastore/assets/SetupAssetsStore.sh

#${HOME}/complete_ws.sh &
#/bin/touch ${HOME}/runtime/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK
#/usr/bin/touch ${HOME}/runtime/WEBSERVER_READY


#while ( [ ! -f ${HOME}/runtime/installedsoftware/InstallPHPBase.sh ] )
#do#
#	/bin/sleep 10
#done

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Sending notification email"
/bin/echo "${0} Sending notification email that a webserver has been built" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

${HOME}/providerscripts/email/SendEmail.sh "A WEBSERVER HAS BEEN SUCCESSFULLY BUILT" "A Webserver has been successfully built and primed as is rebooting ready for use" "INFO"


${HOME}/providerscripts/utilities/processing/UpdateIPs.sh
${HOME}/providerscripts/application/configuration/SetApplicationConfiguration.sh
${HOME}/providerscripts/utilities/housekeeping/CleanupAfterBuild.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Rebooting post install...."
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log


if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh AUTOSCALED:1`" = "0" ] )
then
	/bin/rm ${HOME}/runtime/BUILD_IN_PROGRESS
fi
/bin/touch ${HOME}/runtime/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK
/usr/bin/touch ${HOME}/runtime/INITIAL_BUILD_WEBSERVER_ONLINE
/usr/bin/touch ${HOME}/runtime/WEBSERVER_READY

${HOME}/providerscripts/utilities/security/EnforcePermissions.sh

#PHP_VERSION="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'PHPVERSION'`"


#while ( [ "`/usr/bin/php -v | /bin/grep ${PHP_VERSION}`" = "" ] )
#do
#	/bin/sleep 1
#done

${HOME}/providerscripts/webserver/RestartWebserver.sh

#${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS} &


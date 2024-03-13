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

#Set the permissions as we want for all the autoscaler infrastructure scripts that we are using
/usr/bin/find ${HOME} -not -path '*/\.*' -type d -print0 | xargs -0 chmod 0755 # for directories
/usr/bin/find ${HOME} -not -path '*/\.*' -type f -print0 | xargs -0 chmod 0500 # for files
/bin/chown ${SERVER_USER}:root ${HOME}/.ssh
/bin/chmod 750 ${HOME}/.ssh

export HOMEDIR=${HOME}
/bin/echo "${HOMEDIR}" > /home/homedir.dat
/bin/echo "export HOME=`/bin/cat /home/homedir.dat` && \"\${1}\" \"\${2}\" \"\${3}\" \"\${4}\" \"\${5}\" \"\${6}\"" > /usr/bin/run
/bin/chmod 750 /usr/bin/run
/bin/echo "export HOME=`/bin/cat /home/homedir.dat` && /usr/bin/run \${HOME}/providerscripts/application/configuration/ApplicationConfigurationUpdate.sh" > /usr/bin/config
/bin/chmod 750 /usr/bin/config


#Setup operational directories if needed
if ( [ ! -d ${HOME}/logs/initialbuild ] )
then
    /bin/mkdir -p ${HOME}/logs/initialbuild
fi

if ( [ ! -d ${HOME}/super ] )
then
    /bin/mkdir ${HOME}/super
fi

/bin/mv ${HOME}/providerscripts/utilities/Super.sh ${HOME}/super
/bin/chmod 400 ${HOME}/super/Super.sh

if ( [ -f ${HOME}/InstallGit.sh ] )
then
    /bin/rm ${HOME}/InstallGit.sh
fi

out_file="initialbuild/webserver-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${out_file}
err_file="initialbuild/webserver-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${err_file}

#Check parameters
###############################################################################################################################
#Remeber if you make any changes to the parameters to this script, it is called in two places, on the Build Client during the
#build process and also on the autoscaler from the BuildWebserver script.
#Both places will need updating to reflect the changes that you make to the parameters
###############################################################################################################################
if ( [ "$1" = "" ]  || [ "$2" = "" ] )
then
    /bin/echo "${0} Usage: ./ws.sh <build archive> <server user>" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
    exit
fi

BUILD_ARCHIVE_CHOICE="${1}"
SERVER_USER="${2}"

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} `/bin/date`: Building a new webserver" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} `/bin/date`: Setting up the build parameters" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log


#Load the environment into memory for convenience

${HOME}/providerscripts/utilities/StoreConfigValue.sh "BUILDARCHIVECHOICE" "${BUILD_ARCHIVE_CHOICE}"

CLOUDHOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'CLOUDHOST'`"
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
ALGORITHM="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'ALGORITHM'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"
WEBSERVER_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"
INFRASTRUCTURE_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPROVIDER'`"
INFRASTRUCTURE_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYUSERNAME'`"
INFRASTRUCTURE_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPASSWORD'`"
INFRASTRUCTURE_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
APPLICATION_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONIDENTIFIER'`"

GIT_EMAIL_ADDRESS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'GITEMAILADDRESS'`"
APPLICATION_LANGUAGE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"
SERVER_TIMEZONE_CONTINENT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"
BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
SSH_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SSHPORT'`"
MACHINE_TYPE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MACHINETYPE'`"
/bin/touch ${HOME}/${MACHINE_TYPE}

#Non standard environment setup process
GIT_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'GITUSER' | /bin/sed 's/#/ /g'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
#BASELINE_SOURCECODE_REPOSITORY="`/bin/grep -a 'APPLICATIONBASELINESOURCECODEREPOSITORY' ${HOME}/.ssh/webserver_configuration_settings.dat | /usr/bin/cut -d':' -f 2-`"
APPLICATION_BASELINE_SOURCECODE_REPOSITORY="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'APPLICATIONBASELINESOURCECODEREPOSITORY' 'stripped' | /bin/sed 's/ /:/g'`"

#Record what everything has actually been set to in case there is a problem...
/bin/echo "##################BUILD ENVIRONMENT SETTINGS#######################" > ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "CLOUDHOST:${CLOUDHOST}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "BUILD_IDENTIFIER:${BUILD_IDENTIFIER}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "ALGORITHM:${ALGORITHM}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "WEBSITE_URL:${WEBSITE_URL}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "DATASTORE_CHOICE:${DATASTORE_CHOICE}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "WEBSERVER_CHOICE:${WEBSERVER_CHOICE}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_PROVIDER:${INFRASTRUCTURE_REPOSITORY_PROVIDER}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_USERNAME:${INFRASTRUCTURE_REPOSITORY_USERNAME}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_PASSWORD:${INFRASTRUCTURE_REPOSITORY_PASSWORD}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_OWNER:${INFRASTRUCTURE_REPOSITORY_OWNER}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "APPLICATION_REPOSITORY_PROVIDER:${APPLICATION_REPOSITORY_PROVIDER}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "APPLICATION_REPOSITORY_OWNER:${APPLICATION_REPOSITORY_OWNER}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "APPLICATION_REPOSITORY_USERNAME:${APPLICATION_REPOSITORY_USERNAME}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "APPLICATION_REPOSITORY_PASSWORD:${APPLICATION_REPOSITORY_PASSWORD}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "APPLICATION_IDENTIFIER:${APPLICATION_IDENTIFIER}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "GIT_EMAIL_ADDRESS:${GIT_EMAIL_ADDRESS}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "APPLICATION_LANGUAGE:${APPLICATION_LANGUAGE}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "SERVER_TIMEZONE_CONTINENT:${SERVER_TIMEZONE_CONTINENT}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "SERVER_TIMEZONE_CITY:${SERVER_TIMEZONE_CITY}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "BUILDOS:${BUILDOS}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "SSH_PORT:${SSH_PORT}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "GIT_USER:${GIT_USER}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "WEBSITE_NAME:${WEBSITE_NAME}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "ROOT_DOMAIN:${ROOT_DOMAIN}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "WEBSITE_DISPLAY_NAME:${WEBSITE_DISPLAY_NAME}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "WEBSITE_DISPLAY_NAME_UPPER:${WEBSITE_DISPLAY_NAME_UPPER}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "WEBSITE_DISPLAY_NAME_LOWER:${WEBSITE_DISPLAY_NAME_LOWER}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "APPLICATION_BASELINE_SOURCECODE_REPOSITORY:${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "##################BUILD ENVIRONMENT SETTINGS#######################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log


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

/bin/touch ${HOME}/runtime/BUILD_IN_PROGRESS

#Initialise Git
/usr/bin/git config --global user.name "${GIT_USER}"
/usr/bin/git config --global user.email ${GIT_EMAIL_ADDRESS}
/usr/bin/git config --global init.defaultBranch main
/usr/bin/git config --global pull.rebase false 

. ${HOME}/providerscripts/utilities/InitialiseHostname.sh

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


>&2 /bin/echo "${0} Update.sh"
${HOME}/installscripts/Update.sh ${BUILDOS}

#>&2 /bin/echo "${0} Upgrade.sh"
#${HOME}/installscripts/Upgrade.sh ${BUILDOS}

>&2 /bin/echo "${0} InstallCurl.sh"
${HOME}/installscripts/InstallCurl.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallLibioSocketSSL.sh"
${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallLibnetSSLLeay.sh"
${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallSendEmail.sh"
${HOME}/installscripts/InstallSendEmail.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallJQ.sh"
${HOME}/installscripts/InstallJQ.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallUnzip.sh"
${HOME}/installscripts/InstallUnzip.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallSSHPass.sh"
${HOME}/installscripts/InstallSSHPass.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallSysStat.sh"
${HOME}/installscripts/InstallSysStat.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallUFW.sh"
${HOME}/installscripts/InstallUFW.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallS3FS.sh"
${HOME}/installscripts/InstallS3FS.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallGoofyFS.sh"
${HOME}/installscripts/InstallGoofyFS.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallRsync.sh"
${HOME}/installscripts/InstallRsync.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallCron.sh"
${HOME}/installscripts/InstallCron.sh ${BUILDOS}

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh ENABLEEFS:1`" = "1" ] )
then
    >&2 /bin/echo "${0} InstallNFS.sh"
    ${HOME}/installscripts/InstallNFS.sh ${BUILDOS}
fi

${HOME}/installscripts/InstallMonitoringGear.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Setting Timezone"
/bin/echo "${0}: Setting timezone" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#Set the time on the machine

if ( [ "`/usr/bin/timedatectl list-timezones | /bin/grep ${SERVER_TIMEZONE_CONTINENT} | /bin/grep ${SERVER_TIMEZONE_CITY}`" != "" ] )
then
     /usr/bin/timedatectl set-timezone ${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}
    ${HOME}/providerscripts/utilities/StoreConfigValue.sh "SERVERTIMEZONECONTINENT" "${SERVER_TIMEZONE_CONTINENT}"
    ${HOME}/providerscripts/utilities/StoreConfigValue.sh "SERVERTIMEZONECITY" "${SERVER_TIMEZONE_CITY}"
    export TZ=":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}"
fi

#Do rudimentary checks that the software has been installed correctly
if ( [ -f /usr/bin/curl ] && [ -f /usr/bin/sendemail ] && [ -f /usr/bin/jq ] && [ -f /usr/bin/unzip ] )
then
    /bin/echo "${0} `/bin/date` : It looks like all the required software has installed correctly." >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
else
    /bin/echo "${0} `/bin/date` : It looks like all the required software hasn't installed correctly." >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
    exit
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installing Cloudhost Tools"
/bin/echo "${0} Installing cloudhost tools" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

cd ${HOME}

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installing Datastore tools"
/bin/echo "${0} Installing Datastore tools" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
. ${HOME}/installscripts/InstallDatastoreTools.sh
. ${HOME}/providerscripts/datastore/InitialiseDatastoreConfig.sh

# Install the language engine for whatever language your application is written in
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installing Application Language"
/bin/echo "${0} Installing Application Language: ${APPLICATION_LANGUAGE}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
${HOME}/providerscripts/webserver/InstallApplicationLanguage.sh "${APPLICATION_LANGUAGE}"

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installing Webserver"
/bin/echo "${0} Installing Webserver: ${WEBSERVER_CHOICE} for ${WEBSITE_NAME} at: ${WEBSITE_URL}" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "`${HOME}/providerscripts/utilities/GetIP.sh` ${WEBSITE_NAME}WS" >> /etc/hosts
${HOME}/providerscripts/webserver/InstallWebserver.sh 

cd ${HOME}

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Disabling password authentication"
/bin/echo "${0} `/bin/date`: Disabling password authentication" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

/bin/sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
/bin/sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Changing our preferred SSH port"
/bin/echo "${0} `/bin/date`: Changing to our preferred SSH port" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

if ( [ -f /etc/systemd/system/ssh.service.d/00-socket.conf ] )
then
    /bin/rm /etc/systemd/system/ssh.service.d/00-socket.conf
    /bin/systemctl daemon-restart
fi

/bin/systemctl disable --now ssh.socket
/bin/systemctl enable --now ssh.service

if ( [ "`/bin/grep '^#Port' /etc/ssh/sshd_config`" != "" ] || [ "`/bin/grep '^Port' /etc/ssh/sshd_config`" != "" ] )
then
    /bin/sed -i "s/^Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
    /bin/sed -i "s/^#Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
else
    /bin/echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Preventing root logins"
/bin/echo "${0} `/bin/date`: Preventing root logins" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#Double down on preventing logins as root. We already tried, but, make absolutely sure because we can't guarantee format of /etc/ssh/sshd_config

if ( [ "`/bin/grep '^#PermitRootLogin' /etc/ssh/sshd_config`" != "" ] || [ "`/bin/grep '^PermitRootLogin' /etc/ssh/sshd_config`" != "" ] )
then
    /bin/sed -i "s/^PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
    /bin/sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
else
    /bin/echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi

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

/usr/sbin/service sshd restart

if ( [ ! -d /var/www/html ] )
then
    /bin/mkdir -p /var/www/html > /dev/null 2>&1
fi
cd /var/www/html
/bin/rm -r /var/www/html/* > /dev/null 2>&1
/bin/rm -r /var/www/html/.git > /dev/null 2>&1
/usr/bin/git init

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installing the custom application"
/bin/echo "${0} Installing the custom application" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

. ${HOME}/providerscripts/application/InstallApplication.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Applying application specific customisations"
/bin/echo "${0} Applying application specific customisations" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
. ${HOME}/providerscripts/application/branding/ApplyApplicationBranding.sh
. ${HOME}/providerscripts/application/customise/CustomiseApplication.sh
${HOME}/providerscripts/application/customise/AdjustApplicationInstallationByApplication.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Adjusting webroot permissions and ownerships"
/bin/echo "${0} Adjusting webroot permissions and ownerships" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/chown -R www-data:www-data /var/www/* > /dev/null 2>&1
/usr/bin/find /var/www -type d -exec chmod 755 {} \;
/usr/bin/find /var/www -type f -exec chmod 644 {} \;
/bin/chmod 755 /var/www/html
/bin/chown www-data:www-data /var/www/html

#The applications record which database engine they are expecting to be running, postgres or mysql. 
#It is possible that someone (someone else) stored a postgres database and is deploying a MySQL by mistake, so, check for that and
#swap engines if we find that there is a mismatch between the engine being used and the engine we expect. 

webroot_database_engine="`/bin/cat /var/www/html/dbe.dat`"

if ( [ "${webroot_database_engine}" != "" ] )
then
    DATABASE_INSTALLATION_TYPE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATABASEINSTALLATIONTYPE'`"

    if ( [ "${webroot_database_engine}" = "Postgres" ] )
    then
        if ( [ "${DATABASE_INSTALLATION_TYPE}" != "Postgres" ] )
        then
            ${HOME}/providerscripts/utilities/StoreConfigValue.sh "DATABASEINSTALLATIONTYPE" "Postgres"
        fi
    fi

    if ( [ "${webroot_database_engine}" = "MySQL" ] )
    then
        if ( [ "${DATABASE_INSTALLATION_TYPE}" != "MySQL" ] )
        then
            ${HOME}/providerscripts/utilities/StoreConfigValue.sh "DATABASEINSTALLATIONTYPE" "MySQL"
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
>&2 /bin/echo "${0} Installing database client"
/bin/echo "${0} Install Database client for accessing the database from the command line easily" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
. ${HOME}/providerscripts/utilities/InstallDatabaseClient.sh

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

/bin/echo "${SERVER_USER} ALL= NOPASSWD:/usr/bin/rsync" >> /etc/sudoers

#Switch logging off on the firewall
/usr/sbin/ufw logging off

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh AUTOSCALED:1`" = "0" ] )
then
    /bin/touch ${HOME}/runtime/INITIAL_BUILD_WEBSERVER
    /bin/rm ${HOME}/runtime/BUILD_IN_PROGRESS
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Sending notification email"
/bin/echo "${0} Sending notification email that a webserver has been built" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

${HOME}/providerscripts/email/SendEmail.sh "A WEBSERVER HAS BEEN SUCCESSFULLY BUILT" "A Webserver has been successfully built and primed as is rebooting ready for use" "INFO"

/bin/touch ${HOME}/runtime/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK

${HOME}/security/SetupFirewall.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Rebooting post install...."
/bin/echo "${0} `/bin/date`: Fake rebooting (to save build time) post install....." >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#Needs to be here so its not absent from the backup
/usr/bin/touch ${HOME}/runtime/WEBSERVER_READY

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh AUTOSCALEFROMBACKUP:1`" = "1" ] )
then
    ${HOME}/providerscripts/backupscripts/BackupEntireMachine.sh
fi

/usr/sbin/shutdown -r now


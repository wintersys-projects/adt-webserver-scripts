#!/bin/sh
######################################################################################
# Description: This script will initialise your crontab for you
# Author: Peter Winter
# Date: 28/01/2017
######################################################################################
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
######################################################################################
######################################################################################
#set -x

#These scripts run every minute
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/webserver/CheckWebserverIsUp.sh ${WEBSERVER_CHOICE}" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/application/configuration/ConfigureDBAccessByApplication.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/application/configuration/InitialiseVirginInstallByApplication.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/application/configuration/InstallConfigurationByApplication.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/AcknowledgeBuildCompletion.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /bin/sleep 30 && ${HOME}/providerscripts/utilities/UpdateIP.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/security/MonitorForNewSSLCertificate.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/MonitorForOverload.sh" >> /var/spool/cron/crontabs/root


if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
then
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/webserver/configuration/AllowGatewayBypass.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/security/GatewayGuardian.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/security/GatewayGuardian.sh" >> /var/spool/cron/crontabs/root
fi

#We have a flag to tell us if one of the webservers has updated the SSL certificate. If so, other webservers don't try.
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/RemoveExpiredLocks.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/cron/ExecuteApplicationSpecificCronjob.sh" >> /var/spool/cron/crontabs/root

if ( [ "`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PERSISTASSETSTOCLOUD'`" = "1" ] )
then
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/datastore/SetupAssetsStore.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/datastore/SetupAssetsStore.sh" >> /var/spool/cron/crontabs/root
fi

/bin/echo "*/10 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/MonitorCron.sh" >> /var/spool/cron/crontabs/root

#Each morning at 6:30 generate static site if we need to you can change this to be whatever periodicity you want if you are generating static sites
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GENERATESTATIC:1`" = "1" ] )
then
    /bin/echo "30 6 * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/datastore/GenerateStaticSite.sh" >> /var/spool/cron/crontabs/root
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh AUTHORISATIONSERVER:1`" = "1" ] )
then
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}"  && ${HOME}/security/UpdateAuthorisationServerIPs.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /bin/sleep 10  && ${HOME}/security/UpdateAuthorisationServerIPs.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /bin/sleep 20  && ${HOME}/security/UpdateAuthorisationServerIPs.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /bin/sleep 30  && ${HOME}/security/UpdateAuthorisationServerIPs.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /bin/sleep 40  && ${HOME}/security/UpdateAuthorisationServerIPs.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /bin/sleep 50  && ${HOME}/security/UpdateAuthorisationServerIPs.sh" >> /var/spool/cron/crontabs/root
fi

/bin/echo "*/1 * * * * export HOME=${HOMEDIR} && ${HOME}/providerscripts/datastore/ObtainBuildClientIP.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/cron/SetupFirewallFromCron.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/MarkedForShutdown.sh" >> /var/spool/cron/crontabs/root

/bin/echo "*/5 * * * * export HOME="${HOMEDIR}" && ${HOME}/security/MonitorFirewall.sh" >> /var/spool/cron/crontabs/root

/bin/echo "*/10 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/MonitorCron.sh" >> /var/spool/cron/crontabs/root

#These scripts run at set times these will make a backup of our webroot to git and also to our datastore if super safe
#Time based backups are not taken for virgin CMS installs. Instead, make a baseline if you want to save a copy of your work and work it out from there once your application is ready

/bin/echo "30 1 * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/EnforcePermissions.sh" >> /var/spool/cron/crontabs/root
/bin/echo "2 * * * * export HOME="${HOMEDIR}" && ${HOME}/cron/BackupFromCron.sh 'HOURLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/root
/bin/echo "30 2 * * * export HOME="${HOMEDIR}" && ${HOME}/cron/BackupFromCron.sh 'DAILY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/root
/bin/echo "30 3 * * 7 export HOME="${HOMEDIR}" && ${HOME}/cron/BackupFromCron.sh 'WEEKLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/root
/bin/echo "30 4 1 * * export HOME="${HOMEDIR}" && ${HOME}/cron/BackupFromCron.sh 'MONTHLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/root
/bin/echo "30 5 1 Jan,Mar,May,Jul,Sep,Nov * export HOME="${HOMEDIR}" && ${HOME}/cron/BackupFromCron.sh 'BIMONTHLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/root

#On a daily basis, check if the ssl certificate has expired. Once it has expired, we will try and issue a new one
/bin/echo "00 4 * * * export HOME="${HOMEDIR}" && ${HOME}/cron/InstallSSLCertificateFromCron.sh" >> /var/spool/cron/crontabs/root
/bin/echo "30 3 * * *  export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/RemoveExpiredLogs.sh" >> /var/spool/cron/crontabs/root

#These scripts run at every predefined interval

/bin/echo "@hourly export HOME="${HOMEDIR}" && ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh \"backuplock.*.file\"" >> /var/spool/cron/crontabs/root
/bin/echo "@hourly export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/LoadMonitoring.sh" >> /var/spool/cron/crontabs/root

/bin/echo "@daily export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/PerformSoftwareUpdate.sh" >> /var/spool/cron/crontabs/root

/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/webserver/RestartWebserver.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/application/configuration/InstallConfigurationByApplication.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/CleanupAtReboot.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/PerformSoftwareUpdate.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/GetIP.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME=${HOMEDIR} && ${HOME}/providerscripts/utilities/UpdateInfrastructure.sh" >>/var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/RemoveExpiredLocks.sh reboot" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/LoadMonitoring.sh 'reboot'" >> /var/spool/cron/crontabs/root

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh AUTOSCALEFROMSNAPSHOTS:1`" = "1" ] )
then
    /bin/echo "@reboot export HOME="${HOMEDIR}" &&  ${HOME}/providerscripts/application/SyncLatestApplication.sh" >> /var/spool/cron/crontabs/root
fi

SERVER_TIMEZONE_CONTINENT="`export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"
/bin/echo "@reboot export TZ=\":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}\"" >> /var/spool/cron/crontabs/root


#restart cron
/usr/bin/crontab -u root /var/spool/cron/crontabs/root
if ( [ -f /var/spool/cron/crontabs/www-data ] )
then
    /usr/bin/crontab -u www-data /var/spool/cron/crontabs/www-data
fi

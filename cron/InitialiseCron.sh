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

if ( [ -f /var/spool/cron/crontabs/root ] )
then
	/bin/rm /var/spool/cron/crontabs/root
fi

/bin/echo "MAILTO=''" > /var/spool/cron/crontabs/root
HOME="`/bin/cat /home/homedir.dat`"


if ( [ "`/usr/bin/hostname | /bin/grep "^auth-"`" != "" ] )
then
	WEBSERVER_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"
	/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/providerscripts/webserver/CheckWebserverIsUp.sh ${WEBSERVER_CHOICE}" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/providerscripts/webserver/configuration/authenticator/AcceptIPAddresses.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 10 && ${HOME}/providerscripts/webserver/configuration/authenticator/AcceptIPAddresses.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 20 && ${HOME}/providerscripts/webserver/configuration/authenticator/AcceptIPAddresses.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 30 && ${HOME}/providerscripts/webserver/configuration/authenticator/AcceptIPAddresses.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 40 && ${HOME}/providerscripts/webserver/configuration/authenticator/AcceptIPAddresses.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 50 && ${HOME}/providerscripts/webserver/configuration/authenticator/AcceptIPAddresses.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/providerscripts/webserver/configuration/authenticator/GenerateAuthenticationEmails.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 10 && ${HOME}/providerscripts/webserver/configuration/authenticator/GenerateAuthenticationEmails.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 20 && ${HOME}/providerscripts/webserver/configuration/authenticator/GenerateAuthenticationEmails.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 30 && ${HOME}/providerscripts/webserver/configuration/authenticator/GenerateAuthenticationEmails.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 40 && ${HOME}/providerscripts/webserver/configuration/authenticator/GenerateAuthenticationEmails.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 50 && ${HOME}/providerscripts/webserver/configuration/authenticator/GenerateAuthenticationEmails.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * /usr/bin/find /var/www/html/* -name 'ip-address*.php' -mmin +5 -type f -exec rm -fv {} \;" >> /var/spool/cron/crontabs/root
	/bin/echo "22 4 * * * export HOME="${HOME}" && ${HOME}/utilities/software/UpdateSoftware.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "10 4 * * * export HOME="${HOME}" && ${HOME}/cron/ReviewSSLCertificateValidityFromCron.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "45 4 * * * export HOME="${HOME}" && /bin/rm ${HOME}/runtime/FIREWALL-ACTIVE" >> /var/spool/cron/crontabs/root

elif ( [ "`/usr/bin/hostname | /bin/grep "^ws-"`" != "" ] || [ "`/usr/bin/hostname | /bin/grep "\-rp-"`" != "" ] )
then
	WEBSERVER_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"
	NO_REVERSE_PROXY="`${HOME}/utilities/config/ExtractConfigValue.sh 'NOREVERSEPROXY'`"
 	APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"

	if ( [ "${APPLICATION}" = "drupal" ] )
	then
		/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/application/processing/drupal/ValidateCacheStatus.sh" >> /var/spool/cron/crontabs/root
	fi

	if ( [ "${NO_REVERSE_PROXY}" != "0" ] )
	then
		/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/providerscripts/webserver/configuration/reverseproxy/AddNewIPToReverseProxyIPList.sh" >> /var/spool/cron/crontabs/root
	fi

	#These scripts run every minute
	/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/providerscripts/webserver/CheckWebserverIsUp.sh ${WEBSERVER_CHOICE}" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/application/configuration/UpdateApplicationConfiguration.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 30 && ${HOME}/utilities/processing/UpdateIPs.sh" >> /var/spool/cron/crontabs/root
	#/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/application/configuration/InitialiseVirginInstallByApplication.sh" >> /var/spool/cron/crontabs/root
	#/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/security/MonitorForNewSSLCertificate.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/utilities/status/MonitorForOverload.sh" >> /var/spool/cron/crontabs/root

	#We have a flag to tell us if one of the webservers has updated the SSL certificate. If so, other webservers don't try.
	/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/utilities/housekeeping/RemoveExpiredLocks.sh" >> /var/spool/cron/crontabs/root
	/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/cron/ExecuteApplicationSpecificCronjob.sh" >> /var/spool/cron/crontabs/root

	if ( [ "`${HOME}/utilities/config/ExtractConfigValue.sh 'PERSISTASSETSTODATASTORE'`" = "1" ] )
	then
		/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/providerscripts/datastore/assets/SetupAssetsStore.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/providerscripts/datastore/assets/SetupAssetsStore.sh" >> /var/spool/cron/crontabs/root
	fi

	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh SYNCWEBROOTS:1`" = "1" ] )
	then
		/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/utilities/housekeeping/SyncWebroots.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 10 && ${HOME}/utilities/housekeeping/SyncWebroots.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 20 &&${HOME}/utilities/housekeeping/SyncWebroots.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 30 && ${HOME}/utilities/housekeeping/SyncWebroots.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 40 &&${HOME}/utilities/housekeeping/SyncWebroots.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 50 && ${HOME}/utilities/housekeeping/SyncWebroots.sh" >> /var/spool/cron/crontabs/root
	fi

	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh AUTHENTICATIONSERVER:1`" = "1" ] && ( ( [ "`${HOME}/utilities/config/CheckConfigValue.sh NOREVERSEPROXY:0`" != "1" ] && [ "`/usr/bin/hostname | /bin/grep "\-rp-"`" != "" ] ) || ( [ "`${HOME}/utilities/config/CheckConfigValue.sh NOREVERSEPROXY:0`" = "1" ] && [ "`/usr/bin/hostname | /bin/grep "^ws-"`" != "" ] ) ) )
	then
		/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/security/AllowAuthenticatorIPAddress.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 10 && ${HOME}/security/AllowAuthenticatorIPAddress.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 20 &&${HOME}/security/AllowAuthenticatorIPAddress.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 30 && ${HOME}/security/AllowAuthenticatorIPAddress.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 40 &&${HOME}/security/AllowAuthenticatorIPAddress.sh" >> /var/spool/cron/crontabs/root
		/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 50 && ${HOME}/security/AllowAuthenticatorIPAddress.sh" >> /var/spool/cron/crontabs/root
	fi


	#These scripts run at set times these will make a backup of our webroot to git and also to our datastore if super safe
	#Time based backups are not taken for virgin CMS installs. Instead, make a baseline if you want to save a copy of your work and work it out from there once your application is ready

	/bin/echo "30 1 * * * export HOME="${HOME}" && ${HOME}/utilities/security/EnforcePermissions.sh" >> /var/spool/cron/crontabs/root        
	/bin/echo "2 * * * * export HOME="${HOME}" && ${HOME}/cron/BackupFromCron.sh 'HOURLY'" >> /var/spool/cron/crontabs/root
	/bin/echo "30 2 * * * export HOME="${HOME}" && ${HOME}/cron/BackupFromCron.sh 'DAILY'" >> /var/spool/cron/crontabs/root
	/bin/echo "30 3 * * 7 export HOME="${HOME}" && ${HOME}/cron/BackupFromCron.sh 'WEEKLY'" >> /var/spool/cron/crontabs/root
	/bin/echo "30 4 1 * * export HOME="${HOME}" && ${HOME}/cron/BackupFromCron.sh 'MONTHLY'" >> /var/spool/cron/crontabs/root
	/bin/echo "30 5 1 Jan,Mar,May,Jul,Sep,Nov * export HOME="${HOME}" && ${HOME}/cron/BackupFromCron.sh 'BIMONTHLY'" >> /var/spool/cron/crontabs/root
fi

/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/cron/SetupFirewallFromCron.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/utilities/status/MarkedForShutdown.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/utilities/status/CheckNetworkManagerStatus.sh" >> /var/spool/cron/crontabs/root

/bin/echo "*/5 * * * * export HOME="${HOME}" &&  /bin/sleep 23 && ${HOME}/security/MonitorFirewall.sh" >> /var/spool/cron/crontabs/root

/bin/echo "*/10 * * * * export HOME="${HOME}" && ${HOME}/utilities/status/MonitorCron.sh" >> /var/spool/cron/crontabs/root
#On a daily basis, check if the ssl certificate has expired. Once it has expired, we will try and issue a new one
/bin/echo "10 4 * * * export HOME="${HOME}" && ${HOME}/cron/ReviewSSLCertificateValidityFromCron.sh" >> /var/spool/cron/crontabs/root
/bin/echo "30 3 * * *  export HOME="${HOME}" && ${HOME}/utilities/housekeeping/RemoveExpiredLogs.sh" >> /var/spool/cron/crontabs/root
/bin/echo "22 4 * * *  export HOME="${HOME}" && ${HOME}/utilities/software/UpdateSoftware.sh" >> /var/spool/cron/crontabs/root

#These scripts run at every predefined interval
/bin/echo "@hourly export HOME="${HOME}" && ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh \"backuplock.*.file\"" >> /var/spool/cron/crontabs/root
/bin/echo "@hourly export HOME="${HOME}" && ${HOME}/utilities/status/LoadMonitoring.sh" >> /var/spool/cron/crontabs/root

/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/utilities/status/CheckNetworkManagerStatus.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/providerscripts/webserver/RestartWebserver.sh" >> /var/spool/cron/crontabs/root
#/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/application/configuration/InstallConfigurationByApplication.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/utilities/housekeeping/CleanupAtReboot.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/utilities/processing/GetIP.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME=${HOME} && ${HOME}/utilities/software/UpdateInfrastructure.sh" >>/var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/utilities/housekeeping/RemoveExpiredLocks.sh reboot" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/utilities/status/LoadMonitoring.sh 'reboot'" >> /var/spool/cron/crontabs/root

SERVER_TIMEZONE_CONTINENT="`export HOME="${HOME}" && ${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`export HOME="${HOME}" && ${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"
/bin/echo "@reboot export TZ=\":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}\"" >> /var/spool/cron/crontabs/root


#restart cron
/usr/bin/crontab -u root /var/spool/cron/crontabs/root
if ( [ -f /var/spool/cron/crontabs/www-data ] )
then
	/usr/bin/crontab -u www-data /var/spool/cron/crontabs/www-data
fi

${HOME}/utilities/processing/RunServiceCommand.sh "cron" restart

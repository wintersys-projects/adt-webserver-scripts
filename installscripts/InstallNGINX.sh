#!/bin/sh
######################################################################################################
# Description: This script will install the nginx webserver
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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
#######################################################################################################

if ( [ "${1}" != "" ] )
then
	buildos="${1}"
fi

if ( [ "${buildos}" = "" ] )
then
	BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
else 
	BUILDOS="${buildos}"
fi

MOD_SECURITY="`${HOME}/utilities/config/ExtractConfigValue.sh 'MODSECURITY'`"
NO_REVERSE_PROXY="`${HOME}/utilities/config/ExtractConfigValue.sh 'NOREVERSEPROXY'`"


apt=""
if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-get" ] )
then
	apt="/usr/bin/apt-get"
fi

/usr/bin/systemctl disable apache2 && /usr/bin/systemctl stop apache2 2>/dev/null

export DEBIAN_FRONTEND=noninteractive
update_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y update " 
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 

${HOME}/installscripts/PurgeApache.sh

count="0"
while ( [ ! -f /usr/sbin/nginx ] && [ "${count}" -lt "5" ] )
do
	if ( [ "${apt}" != "" ] )
	then
		/usr/bin/systemctl disable --now apache2 2>/dev/null
		if ( [ "${BUILDOS}" = "ubuntu" ] )
		then
			${HOME}/installscripts/PurgeApache.sh
			if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "NGINX" | /usr/bin/awk -F':' '{print $NF}'`" != "cloud-init" ] )
			then
				if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] )
				then
					if ( [ ! -f /etc/nginx/BUILT_FROM_SOURCE ] )
					then
						software_package_list="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "NGINX:software-packages" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/software-packages//g' | /bin/sed 's/^ //g'`"
						if ( [ "${software_package_list}" != "" ] )
						then
							eval ${install_command} ${software_package_list}
						fi
						if ( [ "${MOD_SECURITY}" = "1" ] )
						then
							if ( ( [ "${NO_REVERSE_PROXY}" = "0" ] || ( [ "${NO_REVERSE_PROXY}" != "0" ] && [ "`/usr/bin/hostname | /bin/grep '\-rp-'`" != "" ] ) ) || [ "`/usr/bin/hostname | /bin/grep 'auth-'`" != "" ] )
							then
								${install_command} g++ apt-utils autoconf automake build-essential libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre2-dev libtool libxml2-dev libyajl-dev pkgconf zlib1g-dev
								${HOME}/installscripts/modsecurity/ConfigureModSecurityForNginx.sh
							fi
						fi
						${HOME}/installscripts/nginx/BuildNginxFromSource.sh "Ubuntu"  			
					fi

					#Make sure nginx avaiable as a service and enable and start it
					if ( [ ! -f /lib/systemd/system/nginx.service ] )
					then
						/bin/cp ${HOME}/installscripts/nginx/nginx.service /lib/systemd/system/nginx.service
						${HOME}/utilities/processing/RunServiceCommand.sh nginx restart
					fi
				elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'NGINX:repo'`" = "1" ] )
				then
					eval ${install_command} nginx	
					/bin/systemctl unmask nginx.service	
					modules_list="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "NGINX:modules-list" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/modules-list//g' | /bin/sed 's/^ //g'`"
					if ( [ "${modules_list}" != "" ] )
					then
						eval ${install_command} ${modules_list}
					fi
					/bin/touch /etc/nginx/BUILT_FROM_REPO							
				fi
			fi
		fi

		if ( [ "${BUILDOS}" = "debian" ] )
		then
			${HOME}/installscripts/PurgeApache.sh
			if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "NGINX" | /usr/bin/awk -F':' '{print $NF}'`" != "cloud-init" ] )
			then
				if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] )
				then
					if ( [ ! -f /etc/nginx/BUILT_FROM_SOURCE ] )
					then
						software_package_list="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "NGINX:software-packages" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/software-packages//g' | /bin/sed 's/^ //g'`"
						if ( [ "${software_package_list}" != "" ] )
						then
							eval ${install_command} ${software_package_list}
						fi

						if ( [ "${MOD_SECURITY}" = "1" ] )
						then
							if ( ( [ "${NO_REVERSE_PROXY}" = "0" ] || ( [ "${NO_REVERSE_PROXY}" != "0" ] && [ "`/usr/bin/hostname | /bin/grep '\-rp-'`" != "" ] ) ) || [ "`/usr/bin/hostname | /bin/grep 'auth-'`" != "" ] )
							then
								${install_command} g++ apt-utils autoconf automake build-essential libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre2-dev libtool libxml2-dev libyajl-dev pkgconf zlib1g-dev
								${HOME}/installscripts/modsecurity/ConfigureModSecurityForNginx.sh
							fi
						fi
						${HOME}/installscripts/nginx/BuildNginxFromSource.sh "Debian"        		
					fi
					#Make sure nginx avaiable as a service and enable and start it
					if ( [ ! -f /lib/systemd/system/nginx.service ] )
					then
						/bin/cp ${HOME}/installscripts/nginx/nginx.service /lib/systemd/system/nginx.service
						${HOME}/utilities/processing/RunServiceCommand.sh nginx restart
					fi
				elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'NGINX:repo'`" = "1" ] )
				then   
					eval ${install_command} nginx	
					modules_list="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "NGINX:modules-list" "stripped" | /bin/sed 's/:/ /g' | /bin/sed 's/modules-list//g' | /bin/sed 's/^ //g'`"
					if ( [ "${modules_list}" != "" ] )
					then
						eval ${install_command} ${modules_list}
					fi
					/bin/systemctl unmask nginx.service							
					/bin/touch /etc/nginx/BUILT_FROM_REPO						
				fi
			fi
		fi			
	fi
	count="`/usr/bin/expr ${count} + 1`"
done

if ( [ ! -f /usr/sbin/nginx ] && [ "${count}" = "5" ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR NGINX" "I believe that nginx hasn't installed correctly, please investigate" "ERROR"
else
	/bin/touch ${HOME}/runtime/installedsoftware/InstallNGINX.sh
fi


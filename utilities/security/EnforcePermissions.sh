#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: This script will enforce filesystem permissions and can be modified according
# to how you want your server secured
#######################################################################################
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
########################################################################################
########################################################################################
#set -x

HOME="`/bin/cat /home/homedir.dat`"

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

/bin/chmod 755 /var/www/html
/bin/chmod 400 /var/www/html/.htaccess
/bin/chown www-data:www-data /var/www/html
/bin/chown www-data:www-data /var/www/html/.htaccess

/usr/bin/find ${HOME} -type d -exec chmod 755 {} \;
/usr/bin/find ${HOME} -type f -exec chmod 750 {} \;
/usr/bin/find ${HOME} -type d -exec chown ${SERVER_USER}:root {} \;
/usr/bin/find ${HOME} -type f -exec chown ${SERVER_USER}:root {} \;

if ( [ -f ${HOME}/.bashrc ] )
then
        /bin/chmod 644 ${HOME}/.bashrc
        /bin/chown ${SERVER_USER}:root ${HOME}/.bashrc
fi

if ( [ -f ${HOME}/.ssh/webserver_configuration_settings.dat.gz ] )
then
        /bin/chown root:root ${HOME}/.ssh/webserver_configuration_settings.dat.gz
        /bin/chmod 600 ${HOME}/.ssh/webserver_configuration_settings.dat.gz
fi

if ( [ -f ${HOME}/.ssh/webserver_configuration_settings.dat ] )
then
        /bin/chown root:root ${HOME}/.ssh/webserver_configuration_settings.dat
        /bin/chmod 660 ${HOME}/.ssh/webserver_configuration_settings.dat
fi

if ( [ -f ${HOME}/.ssh/buildstyles.dat.gz ] )
then
        /bin/chown root:root ${HOME}/.ssh/buildstyles.dat.gz
        /bin/chmod 660 ${HOME}/.ssh/buildstyles.dat.gz
fi

if ( [ -f ${HOME}/.ssh/buildstyles.dat ] )
then
        /bin/chown root:root ${HOME}/.ssh/buildstyles.dat
        /bin/chmod 660 ${HOME}/.ssh/buildstyles.dat
fi

#If you want to harden the security of your system you  can change the ownerships of these files to root but you won't be able
#to "get rooted" using ${HOME}/super/Super.sh

if ( [ -f ${HOME}/runtime/webserver_configuration_settings.dat ] )
then
        #/bin/chown root:root ${HOME}/runtime/webserver_configuration_settings.dat
        /bin/chmod 660 ${HOME}/runtime/webserver_configuration_settings.dat
fi

if ( [ -f ${HOME}/runtime/buildstyles.dat ] )
then
        #/bin/chown root:root ${HOME}/runtime/buildstyles.dat
        /bin/chmod 660 ${HOME}/runtime/buildstyles.dat
fi

/bin/chmod 700 ${HOME}/.ssh
/bin/chmod 600 ${HOME}/.ssh/authorized_keys
/bin/chmod 600 ${HOME}/.ssh/id_*
/bin/chmod 644 ${HOME}/.ssh/id_*pub

if ( [ -d /var/www/html ] )
then
	directories_to_miss=""
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
	then
		directories_to_miss="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
	fi

	if ( [ "${directories_to_miss}" != "" ] )
	then
		paths_to_miss=""
		for dir in ${directories_to_miss}
		do
			if ( [ "`/bin/echo ${dir} | /bin/grep 'merge='`" != "" ] )
			then
				dir="`/bin/echo ${dir} | /bin/sed 's/merge=//g' | /bin/sed 's/.$//g'`"
			fi
			paths_to_miss="${paths_to_miss} | /bin/grep -v /var/www/html/${dir} "
		done
	fi

	command="/usr/bin/find /var/www/html -name '*' ${paths_to_miss}"

	for node in `eval ${command}` 
	do
		/bin/chown www-data:www-data ${node}
		if ( [ -d ${node} ] )
		then
			/bin/chmod 755 ${node} 
		fi
		if ( [ -f ${node} ] )
		then
			/bin/chmod 644 ${node}
		fi
	done
fi

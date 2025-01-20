#!/bin/sh
####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This script will install the s3cmd datastore tool on your webserver
# it will configure itself based on the template in the subdirectory "configfiles".
# If this tool later changes the format of its configuration the template in configfiles
# will have to be updated to reflect the format changes
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
######################################################################################
######################################################################################
#set -x

export HOME="`/bin/cat /home/homedir.dat`"
S3_HOST_BASE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'S3HOSTBASE'`"

datastore_regions="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'S3HOSTBASE' 'stripped' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g' | /bin/sed 's/config//g'`"

if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTORETOOL:s3cmd'`" = "1" ] )
then
        count="0"
        if ( [ -f ${HOME}/.s3cfg ] )
        then
                for datastore_region in ${datastore_regions}
                do
                        if ( [ "${count}" != "0" ] )
                        then
                                /bin/cp  ${HOME}/.s3cfg  ${HOME}/.s3cfg-${count}
                                /bin/sed -i "s/${primary_datastore_region}/${datastore_region}/" ${HOME}/.s3cfg-${count}
                        elif ( [ "${count}" = "0" ] )
                        then
                                primary_datastore_region="${datastore_region}"
                        fi
                        count="`/usr/bin/expr ${count} + 1`"
                done
        fi
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckBuildStyle.sh 'DATASTORETOOL:s5cmd'`" = "1" ] )
then
        count="0"
        if ( [ -f ${HOME}/.s5cfg ] )
        then
                for datastore_region in ${datastore_regions}
                do
                        if ( [ "${count}" != "0" ] )
                        then
                                /bin/cp  ${HOME}/.s5cfg  ${HOME}/.s5cfg-${count}
                                /bin/echo "host_base = ${datastore_region}" >> ${HOME}/.s5cfg
                        fi
                        count="`/usr/bin/expr ${count} + 1`"
                done
        fi

        if ( [ "${S3_HOST_BASE}" != "" ] )
        then
                /bin/sed -i "s/XXXXHOSTBASEXXXX/${S3_HOST_BASE}/" ${HOME}/.s3cfg
                /bin/echo "host_base = ${S3_HOST_BASE}" >> ${HOME}/.s5cfg
                /bin/echo "alias s5cmd='/usr/bin/s5cmd --credentials-file /root/.s5cfg --endpoint-url https://${S3_HOST_BASE}'" >> /root/.bashrc
        fi
fi
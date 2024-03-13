#!/bin/sh
#########################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This will generate a static copy of your website
#########################################################################################
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
#########################################################################################
#########################################################################################
#set -x

export HOME=`/bin/cat /home/homedir.dat`
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
staticbucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
staticbucket="${staticbucket}-static"

if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTORETOOL:s3cmd'`" = "1" ] )
then
    /usr/bin/s3cmd mb s3://${staticbucket}

    if ( [ ! -d ${HOME}/static ] )
    then
       /bin/mkdir ${HOME}/static
    fi

    /bin/rm -r ${HOME}/static/*
    cd ${HOME}/static

    if ( [ ! -f ${HOME}/EC2 ] )
    then
        host_base="`/bin/grep "^host_base" ${HOME}/.s3cfg | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed 's/ //g'`"
        website_endpoint="http:\/\/%(bucket)s.website-${host_base}"
        /bin/sed -i "s/^website_endpoint.*/website_endpoint=${website_endpoint}/" ${HOME}/.s3cfg
    fi

    /usr/bin/wget --no-check-certificate -e robots=no -k -K  -E -r -l 10 -p -N -F -nH https://${WEBSITE_URL}
    /usr/bin/s3cmd ws-create --ws-index=index.html s3://${staticbucket}
    /usr/bin/s3cmd --no-mime-magic --acl-public --delete-removed sync * s3://${staticbucket}
fi

#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Put files into a bucket in the datastore
#####################################################################################
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

datastore_provider="$1"
file_to_put="$2"
datastore_to_put_in="$3"

if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTORETOOL:s3cmd'`" = "1" ] )
then
	/usr/bin/s3cmd --force --recursive --multipart-chunk-size-mb=5 put ${file_to_put} s3://${datastore_to_put_in}
	file="`/bin/echo ${file_to_put} | /usr/bin/awk -F'/' '{print $NF}'`"
	/usr/bin/s3cmd setacl s3://${datastore_to_put_in}/${file} --acl-private
fi

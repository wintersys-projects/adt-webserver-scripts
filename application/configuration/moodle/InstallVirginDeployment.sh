#!/bin/sh
#############################################################################
# Description: This script will obtain and extract the sourcecode for moodle into 
# the webroot directory# Author: Peter Winter
# Date: 04/01/2017
#################################################################################
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
####################################################################################
####################################################################################
#set -x


if ( [ ! -d ${HOME}/runtime/downloads_work_area ] )
then
        /bin/mkdir -p ${HOME}/runtime/downloads_work_area
fi

cd ${HOME}/runtime/downloads_work_area
SOURCECODE_URL="`/bin/grep "^SOURCECODE_URL" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_URL://g' | /bin/sed 's/:/ /g'`"
SOURCECODE_MD5="`/bin/grep "^SOURCECODE_MD5" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_MD5://g' | /bin/sed 's/:/ /g'`"
SOURCECODE_SHA256="`/bin/grep "^SOURCECODE_SHA256" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_SHA256://g' | /bin/sed 's/:/ /g'`"

/usr/bin/wget https://${SOURCECODE_URL}
/bin/echo "${0} `/bin/date`: Downloaded joomla from ${SOURCECODE_URL}" 

verified_archive_type=""
if ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.zip$'`" != "" ] && ( [ "`/usr/bin/md5sum moodle_*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_MD5}" ] || [ "`/usr/bin/sha256sum moodle_*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA256}" ] ) )
then
        verified_archive_type="zip"
elif ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.tgz$'`" != "" ] && ( [ "`/usr/bin/md5sum moodle_*.tgz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_MD5}" ] || [ "`/usr/bin/sha256sum moodle_*.tgz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA256}" ] ) )
then
        verified_archive_type="tgz"
fi

if ( [ "${verified_archive_type}" != "" ] )
then
        if ( [ "${verified_archive_type}" = "zip" ] )
        then
                /usr/bin/python3 -m zipfile -e moodle_*.${verified_archive_type} /var/www/html/ 
        elif ( [ "${verified_archive_type}" = "tgz" ] )
        then
                /bin/tar xvfz moodle_*.${verified_archive_type} -C /var/www/html/
        fi
        /bin/rm moodle_*.${verified_archive_type}
        /bin/chown -R www-data:www-data /var/www/html/*
        cd ${HOME}
        /bin/echo "success"
fi





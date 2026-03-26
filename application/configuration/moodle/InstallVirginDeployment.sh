#!/bin/sh
#####################################################################################
# Description: This script will download and unpack wordpress. The source url for which
# version of wordpress to use is set in  
# ${BUILD_HOME}/application/descriptors/wordpress.dat
# And this can be set to any valid URL of your choosing which includes alpha, beta and
# release candidate archives of wordpress.
# Tar achives and zip archives are supported and which is used depends on the setting in
# ${BUILD_HOME}/application/descriptors/wordpress.dat. 
# The archives have checksum verifications applied so you have to supply the expected
# and valid checksum(s) for your archive in 
# ${BUILD_HOME}/application/descriptors/wordpress.dat.
# Author: Peter Winter
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
set -x


if ( [ ! -d ${HOME}/runtime/downloads_work_area ] )
then
        /bin/mkdir -p ${HOME}/runtime/downloads_work_area
fi

/bin/rm -r ${HOME}/runtime/downloads_work_area/*

cd ${HOME}/runtime/downloads_work_area
SOURCECODE_URL="`/bin/grep "^SOURCECODE_URL" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_URL://g' | /bin/sed 's/:/ /g'`"
SOURCECODE_MD5="`/bin/grep "^SOURCECODE_MD5" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_MD5://g' | /bin/sed 's/:/ /g'`"
SOURCECODE_SHA256="`/bin/grep "^SOURCECODE_SHA256" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_SHA256://g' | /bin/sed 's/:/ /g'`"

/usr/bin/wget https://${SOURCECODE_URL}
/bin/echo "${0} `/bin/date`: Downloaded moodle from ${SOURCECODE_URL}" 

verified_archive_type=""
short_archive_name="`/bin/echo ${SOURCECODE_URL} | /usr/bin/awk -F'/' '{print $NF}'`"

if ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.zip$'`" != "" ] && ( [ "`/usr/bin/md5sum ${HOME}/runtime/downloads_work_area/${short_archive_name} | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_MD5}" ] || [ "`/usr/bin/sha256sum ${HOME}/runtime/downloads_work_area/${short_archive_name} | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA256}" ] ) )
then
        verified_archive_type="zip"
elif ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.tgz$'`" != "" ] && ( [ "`/usr/bin/md5sum ${HOME}/runtime/downloads_work_area/${short_archive_name} | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_MD5}" ] || [ "`/usr/bin/sha256sum ${HOME}/runtime/downloads_work_area/${short_archive_name} | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA256}" ] ) )
then
        verified_archive_type="tgz"
fi

if ( [ "${verified_archive_type}" != "" ] )
then
        if ( [ "${verified_archive_type}" = "zip" ] )
        then
                /usr/bin/python3 -m zipfile -e moodle-*.${verified_archive_type} /var/www/html/ 
        elif ( [ "${verified_archive_type}" = "tgz" ] )
        then
                /bin/tar xvfz moodle-*.${verified_archive_type} -C /var/www/html/
        fi
        /bin/rm moodle-*.${verified_archive_type}
        /bin/chown -R www-data:www-data /var/www/html/*
        /bin/mv /var/www/html/moodle/* /var/www/html
        /bin/rm -r /var/www/html/moodle
        /bin/mv /var/www/html/public /var/www/html/moodle
        BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
        ${HOME}/installscripts/InstallComposer.sh ${BUILDOS}
        cd /var/www/html
        /usr/local/bin/composer install --no-dev --classmap-authoritative
        cd ${HOME}
        /bin/echo "success"
fi





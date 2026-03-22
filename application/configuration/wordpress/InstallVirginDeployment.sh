#!/bin/sh
#####################################################################################
# Description: This script will obtain and extract the sourcecode for joomla into 
# the webroot directory
# Author: Peter Winter
# Date: 04/01/2017
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
set -x

SOURCECODE_URL="`/bin/grep "^SOURCECODE_URL" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_URL://g' | /bin/sed 's/:/ /g'`"
SOURCECODE_MD5="`/bin/grep "^SOURCECODE_MD5" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_MD5://g' | /bin/sed 's/:/ /g'`"
SOURCECODE_SHA1="`/bin/grep "^SOURCECODE_SHA1" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_SHA1://g' | /bin/sed 's/:/ /g'`"

archive_type=""
if ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.zip$'`" != "" ] )
then
        archive_type="zip"   
fi
if ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.tar.gz$'`" != "" ] )
then
        archive_type="tar.gz" 
fi

/usr/bin/wget https://${SOURCECODE_URL} -O wordpress.${archive_type}
/bin/echo "${0} `/bin/date`: Downloaded wordpress from ${SOURCECODE_URL}" 

verified_archive_type=""
if ( [ "${SOURCECODE_MD5}" = "" ] && [ "${SOURCECODE_SHA1}" = "" ] )
then
        verified_archive_type="${archive_type}"
else
        if ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.zip$'`" != "" ] && ( [ "`/usr/bin/md5sum wordpress.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_MD5}" ] || [ "`/usr/bin/sha1sum wordpress.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA1}" ] ) )
        then
                verified_archive_type="${archive_type}"
        elif ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.tar.gz$'`" != "" ] && ( [ "`/usr/bin/md5sum wordpress.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_MD5}" ] || [ "`/usr/bin/sha1sum wordpress.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA1}" ] ) )
        then
                verified_archive_type="${archive_type}"
        fi
fi

if ( [ "${verified_archive_type}" != "" ] )
then
        if ( [ "${verified_archive_type}" = "zip" ] )
        then
                /usr/bin/python3 -m zipfile -e wordpress.${verified_archive_type} /var/www/html/ 
        elif ( [ "${verified_archive_type}" = "tar.gz" ] )
        then
                /bin/tar xvfz wordpress.${verified_archive_type} -C /var/www/html/
        fi
        webroot_directory="`/bin/grep "^WEBROOT_DIRECTORY:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"

        if ( [ "${webroot_directory}" != "/var/www/html/wordpress" ] && [ "${webroot_directory}" != "" ] )
        then
                /bin/mkdir -p ${webroot_directory}
                /bin/mv /var/www/html/wordpress/* /${webroot_directory}
                /bin/rm -r /var/www/html/wordpress
        fi
        
        /bin/chown www-data:www-data ${webroot_directory}
        /bin/chmod 755 ${webroot_directory}
        /bin/rm wordpress.${verified_archive_type}
        /bin/chown -R www-data:www-data /var/www/html/*
        cd ${HOME}
        /bin/echo "success"
fi

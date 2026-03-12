#!/bin/sh
#####################################################################################
# Description: This script will download and unpack joomla. The source url for which
# version of joomla to use is set in  
# ${BUILD_HOME}/application/descriptors/joomla.dat
# And this can be set to any valid URL of your choosing which includes alpha, beta and
# release candidate archives of joomla.
# Tar achives and zip archives are supported and which is used depends on the setting in
# ${BUILD_HOME}/application/descriptors/joomla.dat. 
# The archives have checksum verifications applied so you have to supply the expected
# and valid checksum(s) for your archive in 
# ${BUILD_HOME}/application/descriptors/joomla.dat.
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
#set -x

if ( [ ! -d ${HOME}/runtime/downloads_work_area ] )
then
        /bin/mkdir -p ${HOME}/runtime/downloads_work_area
fi

cd ${HOME}/runtime/downloads_work_area
SOURCECODE_URL="`/bin/grep "^SOURCECODE_URL" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_URL://g' | /bin/sed 's/:/ /g'`"
SOURCECODE_MD5="`/bin/grep "^SOURCECODE_MD5" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_MD5://g' | /bin/sed 's/:/ /g'`"
SOURCECODE_SHA1="`/bin/grep "^SOURCECODE_SHA1" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_SHA1://g' | /bin/sed 's/:/ /g'`"

archive_type=""
if ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.zip$'`" != "" ] )
then
        archive_type="zip"
elif ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.tar.gz$'`" != "" ] )
then
        archive_type="tar.gz"
fi

/usr/bin/wget https://${SOURCECODE_URL} -O joomla.${archive_type}
/bin/echo "${0} `/bin/date`: Downloaded joomla from ${SOURCECODE_URL}" 

verified_archive_type=""
if ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.zip$'`" != "" ] && ( [ "`/usr/bin/md5sum joomla.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_MD5}" ] || [ "`/usr/bin/sha1sum joomla.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA1}" ] ) )
then
        verified_archive_type="${archive_type}"
elif ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.tar.gz$'`" != "" ] && ( [ "`/usr/bin/md5sum joomla.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_MD5}" ] || [ "`/usr/bin/sha1sum joomla.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA1}" ] ) )
then
        verified_archive_type="${archive_type}"
fi

if ( [ "${verified_archive_type}" != "" ] )
then
        if ( [ "${verified_archive_type}" = "zip" ] )
        then
                /usr/bin/python3 -m zipfile -e joomla.${verified_archive_type} /var/www/html/ 
        elif ( [ "${verified_archive_type}" = "tar.gz" ] )
        then
                /bin/tar xvfz joomla.${verified_archive_type} -C /var/www/html/
        fi
        /bin/rm joomla.${verified_archive_type}
        /bin/chown -R www-data:www-data /var/www/html/*
        cd ${HOME}
        /bin/echo "success"
fi

#This is how we tell ourselves this is a joomla application
/bin/echo "JOOMLA" > /var/www/html/dba.dat
/bin/chown www-data:www-data /var/www/html/dba.dat
        
if ( [ -f ${HOME}/runtime/overridehtaccess/htaccess.conf ] )
then
        /bin/cp ${HOME}/runtime/overridehtaccess/htaccess.conf /var/www/html/.htaccess 
        /bin/chmod 444 /var/www/html/.htaccess
        /bin/chown www-data:www-data /var/www/html/.htaccess
fi

#For ease of use we tell ourselves what database engine this webroot is associated with
if ( [ ! -f /var/www/html/dbe.dat ] || [ "`/bin/cat /var/www/html/dbe.dat`" = "" ] )
then
        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
        then
                /bin/echo "For your information this application requires Maria DB as its database" > /var/www/html/dbe.dat
        fi

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
        then
                /bin/echo "For your information this application requires MySQL as its database" > /var/www/html/dbe.dat
        fi

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
        then
                /bin/echo "For your information this application requires Postgres as its database" > /var/www/html/dbe.dat
        fi

        if ( [ -f /var/www/html/dbe.dat ] )
        then
                /bin/chown www-data:www-data /var/www/html/dbe.dat
                /bin/chmod 600 /var/www/html/dbe.dat
        fi
fi

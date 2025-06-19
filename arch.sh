#!/bin/sh
######################################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This is the script which builds a webserver when a whole machine backup is being used
######################################################################################################
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
#set -x

HOME="`/bin/cat /home/homedir.dat`"

if ( [ -d ${HOME}/logs ] )
then
	/bin/rm -r ${HOME}/logs/*
fi

if ( [ ! -d ${HOME}/logs//initialbuild ] )
then
	/bin/mkdir -p ${HOME}/logs//initialbuild
fi

if ( [ "`/usr/bin/hostname | /bin/grep '^auth-'`" != "" ] )
then
        ${HOME}/utilities/config/StoreConfigValue.sh "WEBSITEURLORIGINAL" "${WEBSITE_URL}"
        WEBSITE_URL="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/[^.]*./auth./'`"
        ${HOME}/utilities/config/StoreConfigValue.sh "WEBSITEURL" "${WEBSITE_URL}"
fi


if ( [ -d /var/www/html ] )
then
  /bin/rm -r /var/www/html/*
fi

APPLICATION_LANGUAGE="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"

if ( [ "${APPLICATION_LANGUAGE}" = "PHP" ] )
then
        /bin/mkdir /run/php
fi

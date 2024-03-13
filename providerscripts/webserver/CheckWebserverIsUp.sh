#!/bin/sh
#########################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Check if the webserver is running and if it isn't try and start it
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

export HOME="`/bin/cat /home/homedir.dat`"

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

# We don't want to be up if we are not secure 
if ( [ ! -f ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ] || [ ! -f ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ] )
then
    exit
fi

webserver_type="${1}"
PHP_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"

if ( [ "${webserver_type}" = "APACHE" ] )
then
    if ( [ "`/usr/bin/ps -ef | /bin/grep php | /bin/grep -v grep`" = "" ] )
    then
        /bin/echo "PHP restarting" >> ${HOME}/runtime/WEBSERVER_RESTARTS
        /usr/sbin/service php${PHP_VERSION}-fpm restart || . /etc/apache2/conf/envvars && /usr/local/apache2/bin/apachectl -k restart 
    fi
    if ( [ "`/usr/bin/ps -ef | /bin/grep apache2 | /bin/grep -v grep`" = "" ] )
    then
            /bin/echo "Apache restarting 1" >> ${HOME}/runtime/WEBSERVER_RESTARTS

        /usr/sbin/service apache2 restart

        if ( [ "`/usr/bin/ps -ef | /bin/grep apache2 | /bin/grep -v grep`" = "" ] )
        then
                    /bin/echo "Apache restarting 2" >> ${HOME}/runtime/WEBSERVER_RESTARTS

            . /etc/apache2/envvars && /usr/local/apache2/bin/apachectl -k restart    
        fi
        if ( [ "`/usr/bin/ps -ef | /bin/grep apache2 | /bin/grep -v grep`" = "" ] )
        then
                    /bin/echo "Apache restarting 3" >> ${HOME}/runtime/WEBSERVER_RESTARTS

            /etc/init.d/apache2 restart
        fi
    fi
fi
if ( [ "${webserver_type}" = "NGINX" ] )
then
    if ( [ "`/usr/bin/ps -ef | /bin/grep php | /bin/grep -v grep`" = "" ] )
    then
        /usr/sbin/service php${PHP_VERSION}-fpm restart
    fi
    if ( [ "`/usr/bin/ps -ef | /bin/grep nginx | /bin/grep -v grep`" = "" ] )
    then
        /usr/sbin/service nginx start
    fi
fi

if ( [ "${webserver_type}" = "LIGHTTPD" ] )
then
    if ( [ "`/usr/bin/ps -ef | /bin/grep php | /bin/grep -v grep`" = "" ] )
    then
        /usr/sbin/service php${PHP_VERSION}-fpm restart
    fi
    if ( [ "`/usr/bin/ps -ef | /bin/grep lighttpd | /bin/grep -v grep`" = "" ] )
    then
        /usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
    fi
fi

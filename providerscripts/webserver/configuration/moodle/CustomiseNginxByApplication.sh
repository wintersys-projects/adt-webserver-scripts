#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will customise the nginx configuration for moodle
####################################################################################
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
#################################################################################
#################################################################################
#set -x

if ( [ -f /var/www/html/index.nginx-debian.html ] )
then
	/bin/rm /var/www/html/index.nginx-debian.html
fi

if ( [ -d /var/www/html/client_body_temp ] )
then
	/bin/rm -r /var/www/html/client_body_temp
fi

if ( [ -d /var/www/html/fastcgi_temp ] )
then
	/bin/rm -r /var/www/html/fastcgi_temp
fi

if ( [ -d /var/www/html/proxy_temp ] )
then
	/bin/rm -r /var/www/html/proxy_temp
fi

if ( [ -d /var/www/html/scgi_temp ] )
then
	/bin/rm -r /var/www/html/scgi_temp
fi

if ( [ -d /var/www/html/uwsgi_temp ] )
then
	/bin/rm -r /var/www/html/uwsgi_temp
fi




#!/bin/sh
###########################################################################################################
# Description: Apply any customisations you want to make to moodle
# Author : Peter Winter
# Date: 17/05/2017
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
#######################################################################################################
#set -x

identifier="${1}"

if ( [ "${identifier}" != "" ] )
then
        if ( [ -d ${HOME}/backups/${identifier} ] )
        then
                if ( [ -f ${HOME}/backups/${identifier}/config.php ] )
                then
                        /bin/rm ${HOME}/backups/${identifier}/config.php
                fi
        fi
        if ( [ -d ${idenfitier} ] )
        then
                if ( [ -f ${identifier}/config.php ] )
                then
                        /bin/rm ${identifier}/config.php
                fi
        fi
else
        if ( [ -d /var/www/moodledata ] )
        then
                if ( [ -d /var/www/html/moodledata  ] )
                then
                        /bin/rm -r /var/www/html/moodledata/*
                else
                        /bin/mkdir /var/www/html/moodledata 
                fi
                /bin/cp -r /var/www/moodledata/* /var/www/html/moodledata
                /bin/chown -R www-data:www-data /var/www/html/moodledata
        fi
fi

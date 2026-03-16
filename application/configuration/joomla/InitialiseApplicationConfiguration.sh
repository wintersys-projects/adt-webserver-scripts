#!/bin/sh
###########################################################################################################
# Description:This script will generate a /var/www/configuration.php using the values that you have set in
#
#        ${BUILD_HOME}/application/descriptors/joomla.dat
#
# If a virgin copy of joomla is being installed, then, /usr/bin/php /var/www/html/installation/joomla.php is used
# when making a non-interactive installation this means that the installer doesn't have to do anything once they 
# have started the build they next thing they will see is a fully configured virgin joomla application. 
# If you are deploying a baseline or a temporal backup then the configuration.php file is manually generated
# based on the values set in 
#
#         ${BUILD_HOME}/application/descriptors/joomla.dat
#
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

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ "`/bin/grep "^INTERACTIVE_APPLICATION_INSTALL" ${HOME}/runtime/application.dat | /bin/sed 's/INTERACTIVE_APPLICATION_INSTALL://g' | /bin/sed 's/:/ /g'`" = "yes" ] )
then
        exit
fi

if ( [ -f /var/www/html/configuration.php ] )
then
        /bin/rm /var/www/html/configuration.php
fi

if ( [ -f /var/www/html/installation/configuration.php-dist ] )
then
        /bin/cp /var/www/html/installation/configuration.php-dist /var/www/html/configuration.php.default
        /bin/chown www-data:www-data /var/www/html/configuration.php.default
fi

if ( [ -f /var/www/html/dbp.dat ] )
then
        dbprefix="`/bin/cat /var/www/html/dbp.dat`"
else
        dbprefix="adt`/usr/bin/tr -dc a-z0-9 </dev/urandom | /usr/bin/head -c 5; /bin/echo`_"
        /bin/echo ${dbprefix} > /var/www/html/dbp.dat
        /bin/chown www-data:www-data /var/www/html/dbp.dat
        /bin/chmod 600 /var/www/html/dbp.dat
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
        HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
        HOST="`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "databaseip/*"`"
fi
DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

if ( [ -f ${HOME}/runtime/application.dat ] )
then
        if ( [ ! -d ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing ] )
        then
                /bin/mkdir -p ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing
        fi

        if ( [ -f ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing/exclusion_list.dat ] )
        then
                /bin/rm ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing/exclusion_list.dat
        fi

        for directory in `/bin/grep "^DIRECTORIES_TO_CREATE:" ${HOME}/runtime/application.dat | /bin/sed 's/DIRECTORIES_TO_CREATE://g' | /bin/sed 's/:/ /g'`
        do
                if ( [ ! -d /var/www/html/${directory} ] )
                then
                        /bin/mkdir -p /var/www/html/${directory}
                fi
                /bin/chmod 755 /var/www/html/${directory}
                /bin/chown www-data:www-data /var/www/html/${directory}
                /bin/echo "/var/www/html/${directory}" >> ${HOME}/runtime/filesystem_sync/webroot-sync/outgoing/exclusion_list.dat
        done

        for directory in `/bin/grep "^DIRECTORIES_TO_CREATE_ABSOLUTE:" ${HOME}/runtime/application.dat | /bin/sed 's/DIRECTORIES_TO_CREATE_ABSOLUTE://g' | /bin/sed 's/:/ /g'`
        do
                if ( [ ! -d ${directory} ] )
                then
                        /bin/mkdir -p ${directory}
                fi
                /bin/chmod -R 755 ${directory}
                /bin/chown -R www-data:www-data ${directory}
        done

        APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
        if ( [ "`/bin/cat /var/www/html/dba.dat`" != "`/bin/echo ${APPLICATION} | /bin/tr '[:lower:]' '[:upper:]'`" ] )
        then 
                ${HOME}/providerscripts/email/SendEmail.sh "APPLICATION TYPE MISMATCH" "Your template thinks it is a different application type to your webroot" "ERROR"
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

        username="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:username=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"
        password="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:password=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"
        db="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:db=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"
        type="`/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:type=" ${HOME}/runtime/application.dat | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s%'%%g"`"

        if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
        then
                cd /var/www/html
                website_name="`/bin/grep "^WEBSITE_NAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
                website_username="`/bin/grep "^WEBSITE_USERNAME:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
                website_password="`/bin/grep "^WEBSITE_PASSWORD:" ${HOME}/runtime/application.dat | /usr/bin/awk -F':' '{print $NF}'`"
                website_user_description="`/bin/grep "^WEBSITE_USER_DESCRIPTION:" ${HOME}/runtime/application.dat |  /usr/bin/awk -F':' '{print $NF}'`"

                /usr/bin/sudo -u www-data /usr/bin/php /var/www/html/installation/joomla.php install --site-name="${website_name}" --admin-user="${website_user_description}" --admin-email="changeme@adt-installation-bootstrap.uk" --admin-username="${website_username}" --admin-password="${website_password}"  --db-type="${type}" --db-host="${HOST}:${DB_PORT}"  --db-user="${username}" --db-pass="${password}" --db-name="${db}"  --db-prefix="${dbprefix}" --no-interaction  

                if ( [ -d /var/www/html/installation ] )
                then
                        /bin/rm -r /var/www/html/installation
                fi
        else
                if ( [ -f /var/www/html/configuration.php.default ] )
                then
                        /bin/cp /var/www/html/configuration.php.default /var/www/html/configuration.php
                else
                        ${HOME}/providerscripts/email/SendEmail.sh "DEFAULT CONFIGURATION FILE ABSENT" "Default joomla configuration file is absent" "ERROR"
                        exit
                fi

                secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
          #      for setting in `/bin/grep "^MANDATORY_INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^MANDATORY_INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
          #      do
          #              label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
          #              value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"
#
 #                       if ( [ "${label}" != "" ] && [ "${value}" != "" ] )
  #                      then
   #                             if ( [ "${label}" = "host" ] )
    #                            then
     #                                   /bin/sed -i "s%\$host =.*$%\$host = '"${HOST}:${DB_PORT}"';%" /var/www/html/configuration.php
      #                          elif ( [ "${label}" = "secret" ] )
       #                         then
        #                                /bin/sed -i "s%\$${label} =.*$%\$${label} = '"${secret}"';%" /var/www/html/configuration.php
         #                       elif ( [ "${label}" = "dbprefix" ] )
          #                      then
           #                             /bin/sed -i "s%\$${label} =.*$%\$${label} = '"${dbprefix}"';%" /var/www/html/configuration.php
            #                    else
             #                           /bin/sed -i "s%\$${label} =.*$%\$${label} = ${value};%" /var/www/html/configuration.php
              #                  fi
         #               fi
          #      done
                  
                /bin/sed -i "s%\$host =.*$%\$host = '"${HOST}:${DB_PORT}"';%" /var/www/html/configuration.php
                /bin/sed -i "s%\$dbprefix =.*$%\$dbprefix = '"${dbprefix}"';%" /var/www/html/configuration.php
                /bin/sed -i "s%\$secret =.*$%\$secret = '"${secret}"';%" /var/www/html/configuration.php
                /bin/sed -i "s%\$username =.*$%\$username = '"${username}"';%" /var/www/html/configuration.php
                /bin/sed -i "s%\$password =.*$%\$password = '"${password}"';%" /var/www/html/configuration.php
                /bin/sed -i "s%\$db =.*$%\$db = '"${db}"';%" /var/www/html/configuration.php
                /bin/sed -i "s%\$type =.*$%\$type = '"${type}"';%" /var/www/html/configuration.php


                if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
                then
                        /bin/sed -i "s%\$dbtype =.*$%\$dbtype = '"mysqli"';%" /var/www/html/configuration.php
                elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] 
                        )
                then
                        /bin/sed -i "s%\$dbtype =.*$%\$dbtype = '"mysqli"';%" /var/www/html/configuration.php
                elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = 
                        "1" ])
                then
                        /bin/sed -i "s%\$dbtype =.*$%\$dbtype = '"pgsql"';%" /var/www/html/configuration.php
                fi

                APPLICATION="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATION'`"
                if ( [ "`/bin/cat /var/www/html/dba.dat`" != "`/bin/echo ${APPLICATION} | /bin/tr '[:lower:]' '[:upper:]'`" ] )
                then
                        ${HOME}/providerscripts/email/SendEmail.sh "APPLICATION TYPE MISMATCH" "Your template thinks it is a different application type to your webroot" "ERROR"
                fi
        fi

        for setting in `/bin/grep "^INDIVIDUAL_SETTING:" ${HOME}/runtime/application.dat | /bin/sed 's/^INDIVIDUAL_SETTING://g' | /bin/sed 's/:/ /g'`
        do
                label="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $1}'`"
                value="`/bin/echo ${setting} | /usr/bin/awk -F'=' '{print $2}'`"
                if ( [ "${label}" != "" ] && [ "${value}" != "" ] )
                then
                        /bin/sed -i "s%\$${label} =.*$%\$${label} = ${value};%" /var/www/html/configuration.php
                fi
        done

        /usr/bin/php -ln /var/www/html/configuration.php

        if ( [ "$?" = "0" ] )
        then
                /bin/chmod 600 /var/www/html/configuration.php
                /bin/chown www-data:www-data /var/www/html/configuration.php
                /bin/touch ${HOME}/runtime/INITIAL_CONFIG_SET
        fi
fi

if ( [ ! -f  ${HOME}/runtime/INITIAL_CONFIG_SET ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "CONFIGURATION FILE ABSENT" "Failed to copy joomla configuration file to the live location during application initiation" "ERROR"
fi

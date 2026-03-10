#!/bin/sh
###################################################################################
# Description: This script will obtain and extract the sourcecode for drupal into 
# the webroot directory
# Author: Peter Winter
# Date: 04/01/2017
##################################################################################
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

HOME="`/bin/cat /home/homedir.dat`"

BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
${HOME}/installscripts/InstallComposer.sh ${BUILDOS}

/usr/bin/sudo -u www-data /usr/local/bin/composer require drush/drush
/bin/ls -s /var/www/html/vendor/bin/drush /usr/sbin/drush

if ( [ ! -d ${HOME}/runtime/downloads_work_area ] )
then
        /bin/mkdir -p ${HOME}/runtime/downloads_work_area
fi

cd ${HOME}/runtime/downloads_work_area

if ( [ "`/bin/grep "^APPLICATION_TYPE:drupal" ${HOME}/runtime/application.dat`" != "" ] )
then
        cd ${HOME}/runtime/downloads_work_area
        SOURCECODE_URL="`/bin/grep "^SOURCECODE_URL" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_URL://g' | /bin/sed 's/:/ /g'`"
        SOURCECODE_MD5="`/bin/grep "^SOURCECODE_MD5" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_MD5://g' | /bin/sed 's/:/ /g'`"
        SOURCECODE_SHA1="`/bin/grep "^SOURCECODE_SHA1" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_SHA1://g' | /bin/sed 's/:/ /g'`"
        SOURCECODE_SHA256="`/bin/grep "^SOURCECODE_SHA256" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_SHA256://g' | /bin/sed 's/:/ /g'`"

        /usr/bin/wget https://${SOURCECODE_URL}
        /bin/echo "${0} `/bin/date`: Downloaded drupal from ${SOURCECODE_URL}" 

        verified_archive_type=""
        if ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.zip$'`" != "" ] && ( [ "`/usr/bin/md5sum drupal-*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_MD5}" ] || [ "`/usr/bin/sha1sum drupal-*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA1}" ] || [ "`/usr/bin/sha256sum drupal-*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA256}" ] ) )
        then
                verified_archive_type="zip"
        elif ( [ "`/bin/echo ${SOURCECODE_URL} | /bin/grep '\.tar.gz$'`" != "" ] && ( [ "`/usr/bin/md5sum drupal-*.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_MD5}" ] || [ "`/usr/bin/sha1sum drupal-*.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA1}" ] || [ "`/usr/bin/sha256sum drupal-*.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_SHA256}" ] ) )
        then
                verified_archive_type="tar.gz"
        fi

        if ( [ "${verified_archive_type}" != "" ] )
        then
                if ( [ "${verified_archive_type}" = "zip" ] )
                then
                        /usr/bin/python3 -m zipfile -e drupal-*.${verified_archive_type} /var/www/html/
                elif ( [ "${verified_archive_type}" = "tar.gz" ] )
                then
                        /bin/tar xvfz drupal-*.${verified_archive_type} -C /var/www/html/
                fi

                /bin/rm drupal-*.${verified_archive_type}
                /bin/mv /var/www/html/drupal-*/* /var/www/html
                /bin/rm -r /var/www/html/drupal-*
                /bin/chown -R www-data:www-data /var/www/html/*
                cd /var/www/html
                /usr/bin/sudo -u www-data /usr/local/bin/composer require drush/drush
                /usr/bin/ln -s /var/www/html/vendor/bin/drush /usr/sbin/drush
                /bin/chmod 755 /var/www/html/vendor/bin/drush.php
                /bin/chmod 755 /var/www/html/vendor/drush/drush/drush
                cd ${HOME}
                /bin/echo "success"
        fi
fi

if ( [ "`/bin/grep "^APPLICATION_TYPE:social" ${HOME}/runtime/application.dat`" != "" ] )
then
        BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
        ${HOME}/installscripts/InstallComposer.sh ${BUILDOS}
        while ( [ ! -f ${HOME}/runtime/installedsoftware/InstallApplicationLanguage.sh ] )
        do
                /bin/sleep 5
        done
        /bin/rm -r /var/www/*
        /bin/mkdir /tmp/scratch.$$
        /bin/chmod 755 /tmp/scratch.$$
        /bin/chown www-data:www-data /tmp/scratch.$$
        /usr/bin/sudo -u www-data /usr/local/bin/composer create-project goalgorilla/social_template:dev-master /tmp/scratch.$$ --no-install --no-interaction --working-dir=/tmp/scratch.$$
   #     /bin/sed -i 's;"web-root": "web/";"web-root": "html/";' /tmp/scratch.$$/composer.json
   #     /bin/sed -i 's;web/;html/;' /tmp/scratch.$$/composer.json
        /bin/mv /tmp/scratch.$$/web /tmp/scratch.$$/html
        cd /tmp/scratch.$$
        /usr/bin/sudo -u www-data /usr/local/bin/composer update
        /usr/bin/sudo -u www-data /usr/local/bin/composer install
        /bin/mv * /var/www/
        cd ${HOME}
        /bin/echo "success"
fi

if ( [ "`/bin/grep "^APPLICATION_TYPE:cms" ${HOME}/runtime/application.dat`" != "" ] )
then
        BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
        ${HOME}/installscripts/InstallComposer.sh ${BUILDOS}
        /bin/rm -r /var/www/*
        /bin/mkdir /tmp/scratch.$$
        /bin/chmod 755 /tmp/scratch.$$
        /bin/chown www-data:www-data /tmp/scratch.$$
        /usr/bin/sudo -u www-data /usr/local/bin/composer create-project drupal/cms /tmp/scratch.$$ --no-install --no-interaction --working-dir=/tmp/scratch.$$
        /bin/sed -i 's;"web-root": "web/";"web-root": "html/";' /tmp/scratch.$$/composer.json
        /bin/sed -i 's;web/;html/;' /tmp/scratch.$$/composer.json
        /bin/mv /tmp/scratch.$$/web /tmp/scratch.$$/html
        cd /tmp/scratch.$$
        /usr/bin/sudo -u www-data /usr/local/bin/composer install 
        /bin/mv * /var/www
        cd ${HOME}
        /bin/echo "success"
fi

#if ( [ "`/bin/grep "^APPLICATION_TYPE:social" ${HOME}/runtime/application.dat`" != "" ] )
#then
 #       cd ${HOME}/runtime/downloads_work_area
 #       SOURCECODE_OPENSOCIAL_URL="`/bin/grep "^SOURCECODE_OPENSOCIAL_URL" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_OPENSOCIAL_URL://g' | /bin/sed 's/:/ /g'`"
 #       SOURCECODE_OPENSOCIAL_MD5="`/bin/grep "^SOURCECODE_OPENSOCIAL_MD5" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_OPENSOCIAL_MD5://g' | /bin/sed 's/:/ /g'`"
 #       SOURCECODE_OPENSOCIAL_SHA1="`/bin/grep "^SOURCECODE_OPENSOCIAL_SHA1" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_OPENSOCIAL_SHA1://g' | /bin/sed 's/:/ /g'`"
 #       SOURCECODE_OPENSOCIAL_SHA256="`/bin/grep "^SOURCECODE_OPENSOCIAL_SHA256" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_OPENSOCIAL_SHA256://g' | /bin/sed 's/:/ /g'`"#

#        /usr/bin/wget https://${SOURCECODE_OPENSOCIAL_URL}
 #       /bin/echo "${0} `/bin/date`: Downloaded social from ${SOURCECODE_OPENSOCIAL_URL}"
#
 #       verified_archive_type=""
  #      if ( [ "`/bin/echo ${SOURCECODE_OPENSOCIAL_URL} | /bin/grep '\.zip$'`" != "" ] && ( [ "`/usr/bin/md5sum social-*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_OPENSOCIAL_MD5}" ] || [ "`/usr/bin/sha1sum social-*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_OPENSOCIAL_SHA1}" ] || [ "`/usr/bin/sha256sum social-*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_OPENSOCIAL_SHA256}" ] ) )
   #     then
    #            verified_archive_type="zip"
     #   elif ( [ "`/bin/echo ${SOURCECODE_OPENSOCIAL_URL} | /bin/grep '\.tar.gz$'`" != "" ] && ( [ "`/usr/bin/md5sum social-*.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_OPENSOCIAL_MD5}" ] || [ "`/usr/bin/sha1sum social-*.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_OPENSOCIAL_SHA1}" ] || [ "`/usr/bin/sha256sum social-*.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_OPENSOCIAL_SHA256}" ] ) )
      #  then
#                verified_archive_type="tar.gz"
 #       fi
#
 #       if ( [ "${verified_archive_type}" != "" ] )
  #      then
#                if ( [ "${verified_archive_type}" = "zip" ] )
 #               then
  #                      /usr/bin/python3 -m zipfile -e social-*.${verified_archive_type} /var/www/
   #             elif ( [ "${verified_archive_type}" = "tar.gz" ] )
    #            then
     #                   /bin/tar xvfz social-*.${verified_archive_type} -C /var/www/
#                fi
#
 #               /bin/rm social-*.${verified_archive_type}
  #              /bin/cp -r /var/www/social/* /var/www/html
  #              /bin/rm -r /var/www/social
  #              /bin/chown -R www-data:www-data /var/www/html/*
  #              cd /var/www/html
  #              cd ${HOME}
  #              /bin/echo "success"
  #      fi
#fi

#if ( [ "`/bin/grep "^APPLICATION_TYPE:cms" ${HOME}/runtime/application.dat`" != "" ] )
#then
 #       cd ${HOME}/runtime/downloads_work_area
  #      SOURCECODE_DRUPALCMS_URL="`/bin/grep "^SOURCECODE_DRUPALCMS_URL" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_DRUPALCMS_URL://g' | /bin/sed 's/:/ /g'`"
   #     SOURCECODE_DRUPALCMS_MD5="`/bin/grep "^SOURCECODE_DRUPALCMS_MD5" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_DRUPALCMS_MD5://g' | /bin/sed 's/:/ /g'`"
    #    SOURCECODE_DRUPALCMS_SHA1="`/bin/grep "^SOURCECODE_DRUPALCMS_SHA1" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_DRUPALCMS_SHA1://g' | /bin/sed 's/:/ /g'`"
     #   SOURCECODE_DRUPALCMS_SHA256="`/bin/grep "^SOURCECODE_DRUPALCMS_SHA256" ${HOME}/runtime/application.dat | /bin/sed 's/SOURCECODE_DRUPALCMS_SHA256://g' | /bin/sed 's/:/ /g'`"
#
 #       /usr/bin/wget https://${SOURCECODE_DRUPALCMS_URL}
 #       /bin/echo "${0} `/bin/date`: Downloaded drupal cms from ${SOURCECODE_DRUPALCMS_URL}"#

#        verified_archive_type=""
 #       if ( [ "`/bin/echo ${SOURCECODE_DRUPALCMS_URL} | /bin/grep '\.zip$'`" != "" ] && ( [ "`/usr/bin/md5sum drupal-cms-*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_DRUPALCMS_MD5}" ] || [ "`/usr/bin/sha1sum drupal-cms-*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_DRUPALCMS_SHA1}" ] || [ "`/usr/bin/sha256sum drupal-cms-*.zip | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_DRUPALCMS_SHA256}" ] ) )
  #      then
   #             verified_archive_type="zip"
    #    elif ( [ "`/bin/echo ${SOURCECODE_DRUPALCMS_URL} | /bin/grep '\.tar.gz$'`" != "" ] && ( [ "`/usr/bin/md5sum drupal-cms-*.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_DRUPALCMS_MD5}" ] || [ "`/usr/bin/sha1sum drupal-cms-*.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_DRUPALCMS_SHA1}" ] || [ "`/usr/bin/sha256sum drupal-cms-*.tar.gz | /usr/bin/awk '{print $1}'`" = "${SOURCECODE_DRUPALCMS_SHA256}" ] ) )
     #   then
      #          verified_archive_type="tar.gz"
   #     fi
#
 #       if ( [ "${verified_archive_type}" != "" ] )
  #      then
   #             if ( [ "${verified_archive_type}" = "zip" ] )
    #            then
     #                   /usr/bin/python3 -m zipfile -e drupal-cms-*.${verified_archive_type} /var/www/
      #          elif ( [ "${verified_archive_type}" = "tar.gz" ] )
  #              then
   #                     /bin/tar xvfz drupal-cms-*.${verified_archive_type} -C /var/www/
    #            fi
#
 #               /bin/rm drupal-cms-*.${verified_archive_type}
  #              /bin/cp -r /var/www/drupal-cms/* /var/www/html
   #             /bin/rm -r /var/www/drupal-cms
  #              /bin/chown -R www-data:www-data /var/www/html/*
  #              cd /var/www/html
  #              cd ${HOME}
  #              /bin/echo "success"
  #      fi
#fi

#if ( [ "`/bin/grep "^APPLICATION_TYPE:cms" ${HOME}/runtime/application.dat`" != "" ] )
#then
 #       /bin/rm -r /var/www/*
  #      /bin/mkdir /tmp/scratch.$$
   #     /bin/chmod 755 /tmp/scratch.$$
  #      /bin/chown www-data:www-data /tmp/scratch.$$
  #      /usr/bin/sudo -u www-data /usr/local/bin/composer create-project drupal/cms /tmp/scratch.$$ --no-install --no-interaction --working-dir=/tmp/scratch.$$
  #      /bin/sed -i 's;"web-root": "web/";"web-root": "html/";' /tmp/scratch.$$/composer.json
  #      /bin/sed -i 's;web/;html/;' /tmp/scratch.$$/composer.json
  #      /bin/mv /tmp/scratch.$$/web /tmp/scratch.$$/html
  #      cd /tmp/scratch.$$
  #      /usr/bin/sudo -u www-data /usr/local/bin/composer install 
  #      /bin/mv * /var/www
  #      /usr/bin/sudo -u www-data /usr/local/bin/composer require drush/drush
  #      /usr/bin/ln -s /var/www/vendor/bin/drush /usr/sbin/drush
  #      /bin/chmod 755 /var/www/vendor/bin/drush.php
  #      /bin/chmod 755 /var/www/vendor/drush/drush/drush
  #      /bin/rm -r /tmp/scratch.$$
  #      cd ${HOME}
  #      /bin/echo "success"
#fi

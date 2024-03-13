#!/bin/sh
##################################################################################
# Description: This scripts will configure the SMTP in the joomla configuration file
# for our selected SMTP provider
# Author: Peter Winter
# Date: 12/01/2017
###################################################################################
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
##################################################################################
##################################################################################
#set -x

#Configure the details of the SMTP provider

SYSTEM_FROM_EMAIL_ADDRESS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SYSTEMFROMEMAILADDRESS'`"
SYSTEM_TO_EMAIL_ADDRESS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SYSTEMTOEMAILADDRESS'`"
EMAIL_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'EMAILUSERNAME'`"
EMAIL_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'EMAILPASSWORD'`"
EMAIL_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'EMAILPROVIDER'`"
WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
    /bin/sed -i "/\$mailer /c\        public \$mailer = \'smtp\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$mailfrom /c\        public \$mailfrom = \'${SYSTEM_FROM_EMAIL_ADDRESS}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$replyto /c\        public \$replyto = \'${SYSTEM_TO_EMAIL_ADDRESS}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$fromname /c\        public \$fromname = \'${WEBSITE_NAME} Webmaster\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$replytoname /c\        public \$replytoname = \'${WEBSITE_NAME} Webmaster\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$smtpauth /c\        public \$smtpauth = \'1\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$smtpuser /c\        public \$smtpuser = \'${EMAIL_USERNAME}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$smtppass /c\        public \$smtppass = \'${EMAIL_PASSWORD}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$smtpsecure /c\        public \$smtpsecure = \'tls\';" ${HOME}/runtime/joomla_configuration.php

    if ( [ "${EMAIL_PROVIDER}" = "1" ] )
    then
         /bin/sed -i "/\$smtpport /c\        public \$smtpport = \'2525\';" ${HOME}/runtime/joomla_configuration.php
         /bin/sed -i "/\$smtphost /c\        public \$smtphost = \'smtp-pulse.com\';" ${HOME}/runtime/joomla_configuration.php
    elif ( [ "${EMAIL_PROVIDER}" = "2" ] )
    then
         /bin/sed -i "/\$smtpport /c\        public \$smtpport = \'587\';" ${HOME}/runtime/joomla_configuration.php
         /bin/sed -i "/\$smtphost /c\        public \$smtphost = \'in-v3.mailjet.com\';" ${HOME}/runtime/joomla_configuration.php
    elif ( [ "${EMAIL_PROVIDER}" = "3" ] )
    then
         /bin/sed -i "/\$smtpport /c\        public \$smtpport = \'587\';" ${HOME}/runtime/joomla_configuration.php
         /bin/sed -i "/\$smtphost /c\        public \$smtphost = \'email-smtp.eu-west-1.amazonaws.com\';" ${HOME}/runtime/joomla_configuration.php
    fi
fi

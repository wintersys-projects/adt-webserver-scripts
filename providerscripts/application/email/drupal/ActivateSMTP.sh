#!/bin/sh
##########################################################################################
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

#To activate SMTP for drupal, you need to  install and configure the SMTP module through the GUI

#Your SMTP credentials are stored in /var/www/drupalsmtp

FROMADDRESS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SYSTEMFROMEMAILADDRESS'`"
USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'EMAILUSERNAME'`"
PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'EMAILPASSWORD'`"
EMAILPROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'EMAILPROVIDER'`"


/bin/echo "##################################################################"
/bin/echo "These are your SMTP credentials settings for your drupal install"
/bin/echo "Please refer to: https://www.socketlabs.com/blog/drupal-smtp/"
/bin/echo "##################################################################"

/bin/echo "FROM ADDRESS: ${FROMADDRESS}" > /var/www/drupalsmtp
/bin/echo "USERNAME: ${USERNAME}" >> /var/www/drupalsmtp
/bin/echo "PASSWORD: ${PASSWORD}" >> /var/www/drupalsmtp
/bin/echo "EMAIL PROVIDER: ${EMAILPROVIDER}" >> /var/www/drupalsmtp
/bin/echo "PORT: 465" >> /var/www/drupalsmtp

/bin/chmod 400 /var/www/drupalsmtp

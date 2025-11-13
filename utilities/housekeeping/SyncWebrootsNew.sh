#!/bin/sh


if ( [ ! -d /var/www/html1 ] )
then
	/bin/mkdir /var/www/html1
	/usr/bin/rsync -au "/var/www/html/" "/var/www/html1"
fi

#exclude the config files for each type of CMS
#Get the directory to exclude from the PERSIST_ASSETS setup

/usr/bin/diff --brief --exclude='.*' --exclude='images' /var/www/html /var/www/html1 | /bin/grep -E "(Only in|differ$)"

#Only in /var/www/html means added
#Only in /var/www/html1 means deleted
#differs means modified

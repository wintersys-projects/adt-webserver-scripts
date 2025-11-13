#!/bin/sh

#set -x


if ( [ ! -d /var/www/html1 ] )
then
        /bin/mkdir /var/www/html1
        /usr/bin/rsync -au "/var/www/html/" "/var/www/html1"
fi

#exclude the config files for each type of CMS
#Get the directory to exclude from the PERSIST_ASSETS setup

/usr/bin/diff --brief --exclude='.*' --exclude='images' /var/www/html /var/www/html1 | /bin/grep -E "(Only in|differ$)" > ./full_webroot_status_report.dat

/bin/grep "differ$" ./full_webroot_status_report.dat | /bin/grep -o ' .*/var/www/html.* ' | /usr/bin/awk '{print $1}' | /bin/sed 's;/var/www/html/;;' > ./modified_webroot_files.dat
/bin/grep "Only in" ./full_webroot_status_report.dat | /bin/grep -o '.*/var/www/html.*' | /bin/grep '/var/www/html:' | /usr/bin/awk '{print $NF}' > ./added_webroot_files.dat
/bin/grep "Only in" ./full_webroot_status_report.dat | /bin/grep -o '.*/var/www/html1.*' | /usr/bin/awk '{print $NF}' > ./deleted_webroot_files.dat


for file in `/bin/cat ./modified_webroot_files.dat`
do
        /bin/cp /var/www/html/${file} /var/www/html1/${file}
done

for file in `/bin/cat ./added_webroot_files.dat`
do
        /bin/cp /var/www/html/${file} /var/www/html1/${file}
done

for file in `/bin/cat ./deleted_webroot_files.dat`
do
        /bin/rm /var/www/html1/${file}
done


#Only in /var/www/html means added
#Only in /var/www/html1 means deleted
#differs means modified

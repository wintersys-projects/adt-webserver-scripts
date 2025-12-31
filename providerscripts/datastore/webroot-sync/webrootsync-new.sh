set -x
exclude_list=`${HOME}/application/configuration/GetApplicationConfigFilename.sh`

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh PERSISTASSETSTODATASTORE:1`" = "1" ] )
then
        for dir in `/usr/bin/mount | /bin/grep -Eo "/var/www/html.* " | /usr/bin/awk '{print $1}' | /usr/bin/tr '\n' ' ' | /bin/sed 's;/var/www/html/;;g'`
        do
                exclude_list="${exclude_list}$|${dir}"
        done
fi

additions=`cd /var/www/html ; /usr/bin/find . -depth -type f | /bin/grep -Ev "(${exclude_list})" | /usr/bin/cpio -pdmv /var/www/html1 2>&1 | /bin/grep -v "not created: newer or same age version exists"`

#tar additions to a tar archive additions.${machine_ip}.tar.gz

config_file="`${HOME}/application/configuration/GetApplicationConfigFilename.sh`"

deletes=`/usr/bin/rsync --dry-run -vr ${command_body} --delete /var/www/html1/ /var/www/html | /usr/bin/head -n +3 | /usr/bin/tail -n +2 | /bin/sed '/^$/d' | /bin/grep -Ev "(${exclude_list})"`

full_path_deletes=""
for file in ${deletes}
do
        full_path_deletes="${full_path_deletes} /var/www/html/${file}"
done

echo ${full_path_deletes}

#add deletes to a .log file deletes.${machine_ip}.log

#delete deletes from /var/www/html1

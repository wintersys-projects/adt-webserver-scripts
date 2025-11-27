dirs="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:/ /g'`"

not_for_merge_mount_dirs=""
mount_dirs_for_merge=""

for setting in ${dirs}
do
        if ( [ "`/bin/echo ${setting} | /bin/grep '^merge='`" != "" ] )
        then
                no_dirs="`/bin/echo ${setting} | sed -E 's/.*(.)/\1/'`"
                bucket_dir="`/bin/echo ${setting} | /bin/sed 's/.$//g' | /bin/sed 's/merge=//g'`"
                count="1"
                while ( [ "${count}" -le "${no_dirs}" ] )
                do
                        mount_dirs_for_merge="${mount_dirs_for_merge}${bucket_dir}${count}:"
                        count="`/usr/bin/expr ${count} + 1`"
                done
        else
                not_for_merge_mount_dirs="${not_for_merge_mount_dirs}${setting}:"
        fi
        mount_dirs_for_merge="`/bin/echo ${mount_dirs_for_merge} | /bin/sed 's/:$/ /g'`"
done

not_for_merge_mount_dirs="`/bin/echo ${not_for_merge_mount_dirs} | /bin/sed 's/:$//g'`"

mount_dirs_for_merge_set=""
for merge_dir in ${mount_dirs_for_merge}
do
        bucket_dir="`/bin/echo ${merge_dir} | /bin/sed 's/:/ /g' | /usr/bin/awk '{print $1}' | /bin/sed 's/[0-9]$//g'`" 
        mount_dirs_for_merge_set="${mount_dirs_for_merge_set}${bucket_dir} ${merge_dir}|"
done

mount_dirs_for_merge_set="`/bin/echo ${mount_dirs_for_merge_set} | /bin/sed 's/|$//g'`"
dirs_to_mount_to="`/bin/echo ${mount_dirs_for_merge_set} | /usr/bin/awk -F '|' '{for (i = 1; i <= NF; i++){print $i}}' | /usr/bin/awk '{print $NF}'`"
dirs_to_merge_to="`/bin/echo ${mount_dirs_for_merge_set} | /usr/bin/awk -F '|' '{for (i = 1; i <= NF; i++){print $i}}' | /usr/bin/awk '{print $1}'`"
dirs_to_mount_to="`/bin/echo ${not_for_merge_mount_dirs}:${dirs_to_mount_to} | /bin/sed 's/:/ /g'`"

echo "full set of mount dirs ${dirs_to_mount_to}"

#perform mount process and once all the mounts are done, perform merge process as below


for dir_to_merge_to in  ${dirs_to_merge_to}
do
        for dir_to_merge in ${dirs_to_mount_to}
        do
                dirs_to_merge="${dirs_to_merge} `/bin/echo "${dir_to_merge}" | /bin/grep -ow "${dir_to_merge_to}[0-9]$"`"
        done
        dirs_to_merge="`/bin/echo ${dirs_to_merge} | /usr/bin/tr '\n' ' '`"

        /bin/echo "Merging ${dirs_to_merge} into ${dir_to_merge_to}"
        dirs_to_merge=""
done

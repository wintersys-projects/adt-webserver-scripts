#dirs="`/bin/echo ${dirs} | /bin/sed 's/:/ /g'`"
#application_asset_dirs="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:/ /g'`"

dirs="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:/ /g'`"

single_dirs=""
merge_dirs=""

for setting in ${dirs}
do
        if ( [ "`/bin/echo ${setting} | /bin/grep '^merge='`" != "" ] )
        then
                no_dirs="`/bin/echo ${setting} | sed -E 's/.*(.)/\1/'`"
                bucket_dir="`/bin/echo ${setting} | /bin/sed 's/.$//g' | /bin/sed 's/merge=//g'`"
                count="1"
                while ( [ "${count}" -le "${no_dirs}" ] )
                do
                        merge_dirs="${merge_dirs}${bucket_dir}${count}:"
                        count="`/usr/bin/expr ${count} + 1`"
                done
        else
                single_dirs="${single_dirs}${setting}:"
        fi
        merge_dirs="`/bin/echo ${merge_dirs} | /bin/sed 's/:$/ /g'`"
done

single_dirs="`/bin/echo ${single_dirs} | /bin/sed 's/:$//g'`"
merge_dirs_set=""
for merge_dir in ${merge_dirs}
do
        bucket_dir="`/bin/echo ${merge_dir} | /bin/sed 's/:/ /g' | /usr/bin/awk '{print $1}' | /bin/sed 's/[0-9]$//g'`" 
        merge_dirs_set="${merge_dirs_set}${bucket_dir} ${merge_dir}|"
done

merge_dirs_set="`/bin/echo ${merge_dirs_set} | /bin/sed 's/|$//g'`"
/bin/echo "Merged directories"
/bin/echo ${merge_dirs_set}
/bin/echo "Single directories"
echo ${single_dirs}

dirs_to_mount_to="`/bin/echo ${merge_dirs_set} | /usr/bin/awk -F '|' '{for (i = 1; i <= NF; i++){print $i}}' | /usr/bin/awk '{print $NF}'`"
dirs_to_merge_to="`/bin/echo ${merge_dirs_set} | /usr/bin/awk -F '|' '{for (i = 1; i <= NF; i++){print $i}}' | /usr/bin/awk '{print $1}'`"

echo "XXXX"
echo "${dirs_to_merge_to}" | /usr/bin/tr '\n' ' '
echo
echo "${single_dirs}:${dirs_to_mount_to}" | /bin/sed -e 's/^://g' -e 's/:$//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/:/ /g'

# when I need to do the mergerfs part find the mount directories and the merged directory like this:

exit

test="images hello media1 media2 media3 test1 test2 test3 test4" 

mount="media"

echo ${test} |/bin/grep -wo "${mount}[0-9]"

dirs="images:merge=media3:merge=test4:hello"

dirs="`/bin/echo ${dirs} | /bin/sed 's/:/ /g'`"

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

#merge_dirs="`/bin/echo ${merge_dirs} | /bin/sed 's/:$//g'`"
single_dirs="`/bin/echo ${single_dirs} | /bin/sed 's/:$//g'`"

directory_set=""

for merge_dir in ${merge_dirs}
do
        bucket_dir="`/bin/echo ${merge_dir} | /bin/sed 's/:/ /g' | /usr/bin/awk '{print $1}' | /bin/sed 's/[0-9]$//g'`" 
        directory_set="${directory_set}${bucket_dir} ${merge_dir}|"
done

directory_set="`/bin/echo ${directory_set} | /bin/sed 's/|$//g'`"

/bin/echo "Merged directories"
/bin/echo ${directory_set}
/bin/echo "Single directories"
echo ${single_dirs}

#combine single_dirs and the bucket_dir into one list and mount them all

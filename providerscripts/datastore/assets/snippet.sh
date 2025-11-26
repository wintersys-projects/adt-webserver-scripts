dirs="merge=images3:merge=media2"

dirs="`/bin/echo ${dirs} | /bin/sed 's/:/ /g'`"

newdirs=""
livedirs=""

for setting in ${dirs}
do
        if ( [ "`/bin/echo ${setting} | /bin/grep '^merge='`" != "" ] )
        then
                no_dirs="`/bin/echo ${setting} | sed -E 's/.*(.)/\1/'`"
                livedir="`/bin/echo ${setting} | /bin/sed 's/.$//g' | /bin/sed 's/merge=//g'`"
                count="1"
                while ( [ "${count}" -le "${no_dirs}" ] )
                do
                        newdirs="${newdirs}${livedir}${count}:"
                        count="`/usr/bin/expr ${count} + 1`"
                done
                livedirs="${livedirs} ${livedir}"
        else
                newdirs="${new_dirs}${setting}:"
        fi
done

dirs="`/bin/echo ${newdirs} | /bin/sed 's/:$//g'`"

echo ${dirs}
echo ${livedirs}

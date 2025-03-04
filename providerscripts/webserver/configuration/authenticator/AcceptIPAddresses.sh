if ( [ ! -d ${HOME}/runtime/authenticator ] )
then
        /bin/mkdir -p ${HOME}/runtime/authenticator 
fi

for ip_address in `/bin/cat /var/www/html/ipaddresses.dat | /usr/bin/awk -F':' '{print $NF}'`
do
        if ( [ "`/usr/bin/expr "${ip_address}" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$'`"  != "0" ] )
        then
                if ( [ "`/bin/grep ${ip_address} ${HOME}/runtime/authenticator/ipaddresses.dat`" = "" ] )
                then
                        /bin/echo "${ip_address}" >> ${HOME}/runtime/authenticator/ipaddresses.dat
                fi
        fi
done

for file in `/usr/bin/find /var/www/html -maxdepth 1 -mindepth 1 -type d -not -path "/var/www/html/images/*" `
do
        /usr/bin/s3cmd sync ${file} s3://crew-nuocial-uk-config-xp79/webroot1`/bin/echo ${file} | /bin/sed 's,/var/www/html,,g'`/ &
        pids="${pids} $!"
done

for pid in ${pids}
do
        wait ${pid}
done

#s3cmd sync /var/www/html/* s3://crew-nuocial-uk-config-xant/webroot/

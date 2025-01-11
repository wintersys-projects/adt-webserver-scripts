if ( [ ! -d ${HOME}/runtime/webroot_processing ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_processing
fi

/usr/bin/find /var/www/html -mindepth 1 -type d -not -path "/var/www/html/images/*"  | /bin/sed 's,/var/www/html,,' > ${HOME}/runtime/webroot_processing/complete_webroot_filelist.dat
/bin/sed -i "s,$,/," ${HOME}/runtime/webroot_processing/complete_webroot_filelist.dat
/usr/bin/find /var/www/html -maxdepth 1 -type f >> ${HOME}/runtime/webroot_processing/complete_webroot_filelist.dat
/usr/bin/gawk -i inplace '{print "/usr/bin/s3cmd --recursive put /var/www/html"$0 " s3://crew-nuocial-uk-config-xp79/webroot"$0}' ${HOME}/runtime/webroot_processing/complete_webroot_filelist.dat

/bin/rm ${HOME}/runtime/webroot_processing/complete_webroot_filelist_chunk*

/usr/bin/split -n l/12 ${HOME}/runtime/webroot_processing/complete_webroot_filelist.dat  ${HOME}/runtime/webroot_processing/complete_webroot_filelist_chunk.dat_

exit

pids=""

for file in `/usr/bin/find ${HOME}/runtime/webroot_processing/complete_webroot_filelist_chunk*`
do
        /bin/sh ${file} &
        pids="${pids} $!"
done

for pid in ${pids}
do
        wait ${pid}
done

/bin/echo "Processing complete"

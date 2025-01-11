if ( [ ! -d ${HOME}/runtime/webroot_processing ] )
then
        /bin/mkdir ${HOME}/runtime/webroot_processing
fi

/usr/bin/find -type d /var/www/html > ${HOME}/runtime/webroot_processing/complete_webroot_filelist.dat

/usr/bin/gawk -i inplace '{print "/usr/bin/s3cmd --recursive put " $0 " s3://crew-nuocial-uk-config-xp79/webroot"}' ${HOME}/runtime/webroot_processing/complete_webroot_filelist.dat

/bin/rm ${HOME}/runtime/webroot_processing/complete_webroot_filelist_chunk*

/usr/bin/split -n l/12 ${HOME}/runtime/webroot_processing/complete_webroot_filelist.dat  ${HOME}/runtime/webroot_processing/complete_webroot_filelist_chunk.dat_

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

/usr/bin/freshclam

if ( [ ! -d ${HOME}/runtime/virus_report ] )
then
  /bin/mkdir -p ${HOME}/runtime/virus_report
fi

/usr/bin/clamscan --max-filesize=2000M --max-scansize=2000M --recursive=yes --infected / > ${HOME}/runtime/virus_report/latest.log


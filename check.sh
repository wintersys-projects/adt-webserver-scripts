
if ( [ -d /var/www/html/uwsgi_temp ] )
then
  /bin/echo "${1}" > /home/output-`date | sed 's/ //g'`
fi

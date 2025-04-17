
if ( [ -d /var/www/html/uwsgi_temp ] )
then
  /bin/echo "${1}" >> /home/output
fi

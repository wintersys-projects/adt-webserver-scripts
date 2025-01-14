  if ( [ "`/usr/bin/ps -ef | /bin/grep apache2 | /bin/grep -v grep`" = "" ] && [ "`/usr/bin/ps -ef | /bin/grep nginx | /bin/grep -v grep`" = "" ] && [ "`/usr/bin/ps -ef | /bin/grep lighttpd | /bin/grep -v grep`" = "" ] )
  then
    echo "0"
  else
    echo "1"
  fi
	

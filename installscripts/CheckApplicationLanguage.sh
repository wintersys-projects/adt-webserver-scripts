

if ( [ "${APPLICATION_LANGUAGE}" = "PHP" ] )
then
  /usr/bin/php -v
  if ( [ "$?" != "0" ] )
  then
    status "Waiting for php to be fully installed...I will check again..."
    /bin/sleep 5
  fi
fi

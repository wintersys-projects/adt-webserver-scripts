
if ( [ -f ${HOME}/runtime/INITIAL_BUILD_WEBSERVER_ONLINE ] || [ -f ${HOME}/runtime/AUTOSCALED_WEBSERVER_ONLINE ] )
then
  /bin/echo "1" 
else
  /bin/echo "0"
fi

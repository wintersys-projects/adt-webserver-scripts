
if ( [ -f ${HOME}/runtime/INITIAL_BUILD_WEBSERVER_ONLINE ] || [ -f ${HOME}/runtime/AUTOSCALED_WEBSERVER_ONLINE ] )
then
  echo "1" 
else
  echo "0"
fi

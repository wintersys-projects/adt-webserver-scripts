


machine_ip="`${HOME}/providerscripts/utilities/processing/GetIP.sh`"

if ( [ ! -f ${HOME}/runtime/webroot_manifests ] )
then
  /bin/mkdir -p ${HOME}/runtime/webroot_manifests
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh failed_webroot_manifest/*-${machine_ip}`" != "" ] )
then
  ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh failed_webroot_manifest/*-${machine_ip} ${HOME}/runtime/webroot_manifests
fi

/bin/cat *incoming* > aggregate

file_name="hello"

youngest_epoch="`/bin/grep "${file_name}" ./aggregate | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/sort -n | /usr/bin/tail -1`"

chosen_manifest="`/bin/grep "${file_name}:${youngest_epoch}" *incoming* | /usr/bin/awk -F':' '{print $1}'`"

/bin/sed -i "/^${file_name}:/d" *incoming*

/bin/echo "${file_name}:${youngest_epoch}" >> ${chosen_manifest}


historical_additions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsync/historical/additions/additions*.tar.gz`"

for addition in ${historical_additions}
do
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webrootsync/historical/additions/${addition}
done

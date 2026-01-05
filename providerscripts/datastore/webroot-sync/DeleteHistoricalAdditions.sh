#!/bin/sh

historical_additions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsync/historical/additions/additions*.tar.gz`"

for addition in ${historical_additions}
do
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webrootsync/historical/additions/${addition}
done

historical_deletions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsync/historical/deletions/deletions*.log`"

for deletion in ${historical_deletions}
do
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webrootsync/historical/deletions/${deletion}
done 

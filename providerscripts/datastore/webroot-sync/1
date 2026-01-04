additions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsync/additions/additions*.tar.gz 2>/dev/null`"

for addition in ${additions}
do
        if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh webrootsync/additions/${addition}`" -gt "300" ] )
        then
                if ( [ "${MULTI_REGION}" != "1" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webrootsync/additions/${addition}
                else
                        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
                        ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${multi_region_bucket}/webrootsync/additions/${addition}
                fi
        fi
done

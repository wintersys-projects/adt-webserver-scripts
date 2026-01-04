MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

deletions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsync/deletions/deletions*.tar.gz 2>/dev/null`"

for deletion in ${deletions}
do
        if ( [ "`${HOME}/providerscripts/datastore/configwrapper/AgeOfConfigFile.sh webrootsync/deletions/${deletion}`" -gt "300" ] )
        then
                if ( [ "${MULTI_REGION}" != "1" ] )
                then
                        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh webrootsync/deletions/${deletion}
                else
                        multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
                        ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${multi_region_bucket}/webrootsync/deletions/${deletion}
                fi
        fi
done

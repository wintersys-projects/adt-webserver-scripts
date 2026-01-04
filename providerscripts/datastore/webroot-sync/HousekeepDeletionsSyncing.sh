set -x
MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

deletions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh deletions yes`"

for deletion in ${deletions}
do
        if ( [ "`/bin/echo ${deletion} | /usr/bin/awk -F'/' '{print $NF}' | /bin/sed 's/\./ /g' | /usr/bin/wc -w`" = "7" ] )
        then
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
        fi
done

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

additions="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh additions`"

for addition in ${additions}
do
        if ( [ "`/bin/echo ${addition} | /bin/sed 's/\./ /g' | /usr/bin/wc -w`" = "8" ] )
        then
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
        fi
done

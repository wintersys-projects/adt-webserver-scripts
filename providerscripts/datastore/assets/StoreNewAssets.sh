WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

directories_to_mount="`${HOME}/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:config//g'`"
directories=""
for directory in ${directories_to_mount}
do
        processed_directories="${processed_directories}`/bin/echo "${directory} " | /bin/sed 's/\./\//g'`"
done

applicationassetdirs="${processed_directories}"
applicationasset_buckets="`/bin/echo ${applicationassetdirs} | /bin/sed 's/\//\-/g'`"

for asset_bucket in ${applicationasset_buckets}
do
        asset_buckets="${asset_buckets} `/bin/echo "${WEBSITE_URL}"-assets | /bin/sed 's/\./-/g'`-${asset_bucket}"
done

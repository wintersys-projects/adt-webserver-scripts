inspected_file="${1}"

if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTORETOOL:s3cmd'`" = "1" ] )
then
  time_file_written="`/usr/bin/s3cmd info s3://${inspected_file}| /bin/grep "Last mod" | /usr/bin/awk -F',' '{print $2}'`"
elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTORETOOL:s5cmd'`" = "1" ]  )
then
  time_file_written="`/usr/bin/s5cmd ls s3://${inspected_file} | /usr/bin/awk '{print $1,$2}'`"
fi

time_file_written="`/usr/bin/date -d "${time_file_written}" +%s`"

time_now="`/usr/bin/date +%s`"
age_of_file_in_seconds="`/usr/bin/expr ${time_now} - ${time_file_written}`"
/bin/echo ${age_of_file_in_seconds}


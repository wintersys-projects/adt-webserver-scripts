
directories_to_miss="`${HOME}/providerscripts/utilities/config/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"

command="/usr/bin/find /var/www/html "
command_body=""
for directory_to_miss in ${directories_to_miss}
do
        command_body="${command_body} -path /var/www/html/${directory_to_miss} -prune -o "
done
command="${command} ${command_body} -type f -mmin -5 -print"

for file in `${command}`
do
        cropped_filename="`/bin/echo ${file} | /bin/sed 's,/var/www/html/,,g'`"
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${file} webroot-update/${cropped_filename}
done

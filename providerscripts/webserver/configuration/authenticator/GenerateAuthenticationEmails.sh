email_list="`/bin/cat /var/www/html/emails.dat | /usr/bin/awk -F':' '{print $NF}'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"

for email_address in ${email_list}
do
        file_name="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
        full_file_name="/var/www/html/ip-address-${file_name}.php"
        /bin/cp ${HOME}/providerscripts/webserver/configuration/authenticator/ip-collector.php ${full_file_name}
        /bin/chown www-data:www-data ${full_file_name}
        /bin/chmod 644 ${full_file_name}
        website_url="https://${WEBSITE_URL}/ip-address-${file_name}.php"
        message="<!DOCTYPE html> <html> <body> <h1>My First Heading</h1> <p>My first paragraph.</p> <a href='"${website_url}"'>Enable Your IP Address</a> </body> </html>"
        ${HOME}/providerscripts/email/SendEmail.sh "Authentication Confirmation Link" "${message}" MANDATORY ${email_address} "HTML"
        /bin/sed -i "/:${email_address}$/d" /var/www/html/emails.dat
done

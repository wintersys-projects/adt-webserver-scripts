email_list="`/bin/cat /var/www/html/emails.dat | /usr/bin/awk -F':' '{print $NF}'`"

for email_address in ${email_list}
do
        file_name="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
        full_file_name="/var/www/html/${file_name}.php"
        /bin/cp /var/www/html/hello.php ${full_file_name}
        /bin/chown www-data:www-data ${full_file_name}
        /bin/chmod 644 ${full_file_name}
        message="<!DOCTYPE html> <html> <body> <h1>My First Heading</h1> <p>My first paragraph.</p> <a href='https://auth.nuocial.uk/${file_name}.php'>Enable Your IP Address</a> </body> </html>"
        ${HOME}/providerscripts/email/SendEmail.sh "Authentication Confirmation Link" "${message}" MANDATORY ${email_address} "HTML"
done

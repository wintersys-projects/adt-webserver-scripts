ssh_client_ips="`/usr/bin/pinky | /usr/bin/awk '{print $NF}' | /usr/bin/tail -n +2`"

if ( [ ! -d ${HOME}/runtime/ssh-audit ] )
then
        /bin/mkdir -p ${HOME}/runtime/ssh-audit
fi

/bin/touch ${HOME}/runtime/ssh-audit/audit_trail

for ssh_client_ip in ${ssh_client_ips}
do
        if ( [ "`/bin/grep ${ssh_client_ip} ${HOME}/runtime/ssh-audit/audit_trail`" = "" ] )
        then
                /bin/echo ${ssh_client_ip} > ${HOME}/runtime/ssh-audit/audit_trail
                ${HOME}/providerscripts/email/SendEmail.sh "SSH CONNECTION FROM A NEW IP ADDRESS" "There has been a new connection from an unknown IP ${ssh_client_ip} to machine `/usr/bin/hostname`" "INFO"
        fi
done

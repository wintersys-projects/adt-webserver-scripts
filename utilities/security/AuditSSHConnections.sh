ssh_client_ip="${SSH_CONNECTION}"
if ( [ ! -d ${HOME}/runtime/ssh-audit ] )
then
	/bin/mkdir -p ${HOME}/runtime/ssh-audit
fi

/bin/touch ${HOME}/runtime/ssh-audit/audit_trail

if ( [ "`/bin/grep ${ssh_client_ip} ${HOME}/runtime/ssh-audit/audit_trail`" = "" ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "SSH CONNECTION FROM A NEW IP ADDRESS" "There has been a new connection from an unknown IP ${ssh_client_ip} to machine `/usr/bin/hostname`" "INFO"
fi

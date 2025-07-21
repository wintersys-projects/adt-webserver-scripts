#set -x

${HOME}/utilities/processing/RunServiceCommand.sh apache2 stop
${HOME}/utilities/processing/RunServiceCommand.sh apache2 disable
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y remove --purge apache2
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y remove --purge apache2-utils
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y remove --purge apache2-bin
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y autoremove --purge  
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y autoclean  

/bin/rm -rf /etc/apache2 
/bin/rm -rf /etc/init.d/apache2 
/bin/rm -rf /usr/sbin/apache2
/bin/rm -rf /var/lib/apache2
/bin/rm -rf /usr/lib/apache2
/bin/rm -rf /var/log/apache2



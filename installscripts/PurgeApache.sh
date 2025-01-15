
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y remove --purge apache2
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y remove --purge apache2-utils
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y remove --purge apache2-bin
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y autoremove --purge  
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y autoclean  

/bin/rm -rf /etc/apache2 /etc/init.d/apache2 /usr/sbin/apache2 /var/lib/apache2 /usr/lib/apache2 /var/log/apache2


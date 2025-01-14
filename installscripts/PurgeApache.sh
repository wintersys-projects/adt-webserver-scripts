/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y autoremove --purge  
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y autoclean  
/usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y remove --purge  

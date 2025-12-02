apt-get install -y gcc make pkg-config cmake build-essential libfuse3-dev
git clone https://github.com/rpodgorny/unionfs-fuse.git
./src/unionfs -o cow,max_files=32768 -o allow_other,suid,dev  /tmp/1=RW:/tmp/2=RW /tmp/3

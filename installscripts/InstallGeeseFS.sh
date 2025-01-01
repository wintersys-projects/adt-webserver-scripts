cwd="`/usr/bin/pwd`"
/usr/bin/git clone https://github.com/yandex-cloud/geesefs
cd geesefs
/usr/bin/go build
if ( [ -f ./geesefs ] )
then
        /bin/cp ./geesefs /usr/sbin
fi
cd ${cwd}
/bin/rm -r ./geesefs

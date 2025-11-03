branch="${1}"

#Allow the branch to be obtained from buildstyles.dat

if ( [ ! -d /home/development ] )
then
/bin/mkdir /home/development
fi

/usr/bin/sync /home/XX/ /home/development

/bin/rm -r /home/X*X/.git

cd /home/development

if ( [ "${1}" = "main" ] )
then
#Send Email about main branch not being suitable for development
:
fi

/usr/bin/git branch ${1}
/usr/bin/git fetch --all
/usr/bin/git checkout ${1}
/usr/bin/git pull origin ${1}

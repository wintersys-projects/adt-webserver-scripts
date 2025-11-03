#set -x

branch="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "GITBRANCH"`"
HOME="`/bin/cat /home/homedir.dat`"

if ( [ ! -d /home/development ] )
then
        /bin/mkdir /home/development
fi

/usr/bin/rsync -a ${HOME}/ /home/development

if ( [ -d ${HOME}/.git ] )
then
        /bin/rm -r ${HOME}/.git
fi

cd /home/development

exit

if ( [ "${1}" = "main" ] )
then
        #Send Email about main branch not being suitable for development
        :
fi

/usr/bin/git branch ${1}
/usr/bin/git fetch --all
/usr/bin/git checkout ${1}
/usr/bin/git pull origin ${1}

#set -x

commit_message="${1}"
branch="${2}"

if ( [ "${branch}" = "" ] )
then
        BRANCH="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "GITBRANCH"`"
else
        BRANCH="${branch}"
fi

if ( [ "${BRANCH}" = "main" ] )
then
        /bin/echo "Direct pushes to the main branch are not allowed"
        exit
fi

if ( [ "${commit_message}" = "" ] )
then
        /bin/echo "Commit message not set"
        exit
fi

/bin/echo "Attempting to push to branch ${BRANCH} with commit message '"${commit_message}"'"
/bin/echo "Press <enter> to confirm <ctrl-c> to exit"
read x

GIT_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'GITUSER'`"
GIT_EMAIL_ADDRESS="`${HOME}/utilities/config/ExtractConfigValue.sh 'GITEMAILADDRESS'`"

/usr/bin/git config --global user.email "${GIT_EMAIL_ADDRESS}"
/usr/bin/git config --global user.name "${GIT_USER}"

/usr/bin/git add . 
/usr/bin/git commit -m "${commit_message}"
/usr/bin/git push -u origin ${BRANCH}

/usr/bin/rsync -a /home/development/ ${HOME}
/bin/chown -R www-data:www-data ${HOME}

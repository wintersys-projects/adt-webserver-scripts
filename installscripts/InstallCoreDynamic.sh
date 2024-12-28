scripts="`cat InstallCore* | grep BUILDOS | grep -v "Up.*" | /usr/bin/awk '{print $1}'`"

package_names=""

for script in ${scripts}
do
        script="`/bin/echo ${script} | /bin/sed -e 's,\${HOME},'${HOME}',g'`"
        package_names="${package_names} `/bin/cat ${script} | /bin/grep DEBIAN_FRONTEND | /usr/bin/awk '{print $8}' | /usr/bin/sort -u | /usr/bin/uniq | /usr/bin/tr '\n' ' '`"
done

apt=""
if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
        apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
        apt="/usr/sbin/apt-fast"
fi

if ( [ "${apt}" != "" ] )
then
        if ( [ "${buildos}" = "ubuntu" ] )
        then
                DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install ${package_names}
        fi
        if ( [ "${buildos}" = "debian" ] )
        then
                DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install ${package_names}
        fi
fi

set -x

BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"


if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDOS:ubuntu`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDOS:debian`" = "1" ] )
then
	${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
fi

for script in `/usr/bin/find ${HOME}/runtime/installedsoftware/ -name "*.sh" -print | /usr/bin/awk -F'/' '{print $NF}'`
do
        /bin/sh ${HOME}/installscripts/${script} ${BUILDOS}
done

${HOME}/providerscripts/utilities/software/UpdateInfrastructure.sh

/usr/sbin/shutdown -r now




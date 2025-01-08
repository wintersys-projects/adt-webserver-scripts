

for interval in "0 10 20 30 40 50"
do
  /bin/sleep ${interval}
  ${HOME}/providerscripts/utilities/housekeeping/RsyncWebroots.sh
done

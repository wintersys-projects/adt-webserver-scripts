uuid="/usr/sbin/blkid | /bin/grep swap | /bin/sed -e 's/.*UUID="//g' -e 's/".*//g'"
/bin/echo "RESUME=UUID=${uuid}" > /etc/initramfs-tools/conf.d/resume
${HOME}/utilities/security/EnforcePermissions.sh

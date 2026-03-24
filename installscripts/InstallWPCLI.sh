

${HOME}/installscripts/InstallGnuPG.sh
/usr/bin/curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
/usr/bin/curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar.asc
/usr/bin/curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/wp-cli.pgp | gpg --import
/usr/bin/gpg --verify wp-cli.phar.asc wp-cli.phar
/bin/chmod +x wp-cli.phar
/bin/mv wp-cli.phar /usr/local/bin/wp

# Verify installation
/usr/local/bin/wp --info

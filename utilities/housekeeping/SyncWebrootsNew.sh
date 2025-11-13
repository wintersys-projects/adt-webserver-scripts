#!/bin/sh


if ( [ ! -d /var/www/html1 ] )
then
	/usr/bin/rsync -au "/var/www/html/" "/var/www/html1"
fi

/usr/bin/diff -x '.*' --brief --exclude=images /var/www/html /var/www/html1 | /bin/grep -E "(Only in|differ$)"

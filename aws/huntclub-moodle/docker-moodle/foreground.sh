#!/bin/bash
set -x

echo "placeholder" > /var/moodledata/placeholder
chown -R www-data:www-data /var/moodledata
chmod 777 /var/moodledata

read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
trap "kill -TERM -$pgrp; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT

#start up cron
/usr/sbin/cron

find /var/run -name 'httpd.pid' -exec rm -f {} \;

sed -ri \
  -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
  -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
  /etc/apache2/* /etc/apache2/*/*

source /etc/apache2/envvars
tail -F /var/log/apache2/* &
exec apache2 -D FOREGROUND

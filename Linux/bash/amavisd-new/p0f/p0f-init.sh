#!/bin/bash -e
### BEGIN INIT INFO
# Provides:          downtimed
# Required-Start:    $local_fs $network $syslog
# Required-Stop:     $local_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop apache2 web server
### END INIT INFO

case "$1" in
  start)
    if [ -f /var/run/p0f.pid ]; then
      echo -e '[ \E[36;31m'"\033\ok\033[0m ] Starting SMTP-Fingerprint Service: p0f (already running)"
   fi

   if [ ! -f /var/run/p0f.pid ]; then
     echo -e '[ \E[36;32m'"\033\ok\033[0m ] Starting SMTP-Fingerprint Service: p0f"
     touch /var/run/p0f.pid
     /usr/sbin/p0f -l -o /var/log/p0f.log 'tcp dst port 25' 2>&1 | /usr/sbin/p0f-analyzer 2345 &
   fi
;;
  stop)
    if [ ! -f /var/run/p0f.pid ]; then
      echo -e '[ \E[36;31m'"\033\ok\033[0m ] Stopping SMTP-Fingerprint Service: p0f (not running)"
    else
      echo -e '[ \E[36;32m'"\033\ok\033[0m ] Stopping SMTP-Fingerprint Service: p0f"
      /bin/kill $(pidof p0f)
      rm /var/run/p0f.pid
  fi
    ;;
  restart)
      $0 stop
      $0 start
    ;;
  status)
    echo "p0f Status:"
    /bin/ps aux |grep p0f | egrep -v '(grep|tail|/bin/)'
    ;;
  *)
    echo "Fehlerhafter Aufruf"
    echo "Syntax: $0 {start|stop|restart}"
    exit 1
    ;;
esac



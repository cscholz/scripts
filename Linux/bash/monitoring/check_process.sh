#!/bin/bash

###########################################################################################
# checks if a process passed as parameter $1 is running. If not a service called $2
# will be started. If the check fails twice no further checks and service start will be
# performed. E-Mail notification for service down and restart is includd
###########################################################################################

RECIPIENT=postmaster@domain.tld
if [[ $1 = "" ]]; then
    echo "incorrect usage; specify the procress name an the command line."
    echo "$0 ps-name [service-name]"
else
    process_pid=$(ps -ef | grep "$1" | grep -v grep | grep -v "$0" | cut -c 10-14)

    if [[ $process_pid = "" ]]; then
      if [ $2 != "" ]; then
#        echo "$1 is down - try to restart"
        /etc/init.d/$2 restart | mail -s "[$(hostname)] - Process $1 down, try restart" $RECIPIENT
        process_pid=$(ps -ef | grep "$1" | grep -v grep | grep -v "$0" | cut -c 10-14)

        if [[ $process_pid = "" ]]; then
          echo "$1 could not restarted - try start only"
	  /etc/init.d/$2 start > /dev/null
	  process_pid=$(ps -ef | grep "$1" | grep -v grep | grep -v "$0" | cut -c 10-14)
	fi
	
	if [[ $process_pid = "" ]]; then
          echo "$1 could not restarted - sending notification email"
          mail $RECIPIENT -s "[$(hostname)] - Process $1 is still down" < /dev/null > /dev/null
        else
#          echo "$1 seems to be running eith PID: $process_pid"
          ps -ef | grep "$1" | grep -v grep | grep -v "$0" | mail -s "[$(hostname)] - Process $1 seems to be running with PID: $process_pid" $RECIPIENT
          exit 0
        fi

      fi

      mail -s "Process $1 is down" $RECIPIENT < /dev/null > /dev/null
    fi

fi

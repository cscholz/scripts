#!/bin/bash
#Programm while.sh

tempfile=$(mktemp)
# modem auslesen
cat /dev/ttyUSB0 > $tempfile &
sleep 5
count=0           #Zähler auf Null setzen

#So lange durchlaufen  bis count nicht mehr unter 10 ist
while [ $count -le 2 ]
      do
	echo -ne "AT+CSQ\r" > /dev/ttyUSB0
	sleep 2
	signal=$(strings $tempfile | grep '[0-9]\+\,[0-9]\{2\}' | awk '{print $2}')
	echo "Signal:" $signal
	sleep 11
	echo -ne "ATZ\r" > /dev/ttyUSB0
	echo > $tempfile
	sleep 2
      done
exit 0





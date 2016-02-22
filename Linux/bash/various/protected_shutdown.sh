#!/bin/bash

# PS4 LAN
ping -c 1 192.168.10.252 &> /dev/null && stop=0

# PS4 WLAN
ping -c 1 192.168.10.251 &> /dev/null && stop=0

if [ "$stop" != "0" ]; then
  shutdown -h -now
fi


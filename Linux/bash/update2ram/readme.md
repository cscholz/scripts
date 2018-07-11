

# README #

### How to install ###

sudo wget -O /etc/systemd/system/update2ram.service https://raw.githubusercontent.com/cscholz/scripts/master/Linux/bash/update2ram/update2ram.service

sudo wget -O /usr/sbin/update2ram.sh https://raw.githubusercontent.com/cscholz/scripts/master/Linux/bash/update2ram/update2ram.sh

sudo chmod +x /usr/sbin/update2ram.sh

sudo systemctl enable update2ram

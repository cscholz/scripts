Web:   http://dpdns.cscholz.io

Style Guide: https://www.cbica.upenn.edu/sbia/software/basis/standard/style/plain.html
             ( http://dpdns.cscholz.io/style.txt )


INTRODUCTION
============

  dpdns.cscholz.io offers a dns blacklist to block adware, spy-ware, windows telemetry channels, porn.
  The blacklist can easily used on a raspberry pi.



USAGE
===============

  Entries are added to the list carefully after testing. Blocking a whole domain via DNS
  keeps the risc to block legitime data.

  To make the usage of the blacklist as easy as possible I offer a script to:
  _ update the blacklist (cron capable)
  _ update the management script
  _ add/remove blacklist entries manuel
  _ raise the version of the local blacklist

  REMAKR: Despite all the care. Use the blacklist and script at your own risk!


INSTALL DPDNS SCRIPT
----------------------
  $ cd /usr/src/local/
  $ wget http://dpdns.cscholz.io/dpdns
  $ chmod +x dpdns

  $ ./dpdns
  |  DATA PRIVACY DNS (v.0.14)
  |
  |  Bind:
  |  -------------------------------
  |  1)   Update DNSBL
  |  2)   Upload DNSBL
  |  3)   Raise DNSBL Version
  |  4)   Convert Bind > DNSMasq
  |
  |  DnsMasq:
  |  -------------------------------
  |  5)   Update DNSBL
  |  6)   Upload DNSBL
  |  7)   Raise DNSBL Version
  |  8)   Convert DNSMasq > Bind
  | 
  |  add) Add domain to blacklist.
  |  rm)  Remove domain from blacklist
  |  u)   Update
  |  h)   help
  |  x)   Exit


BLACKLIST FILE FORMAT
---------------------

  Two files are offered. Bind9 and dnsmasq file format.
  First line contain the current version number of the file (//Version: 20 or #Version: 20)


DOWNLOAD BLACKLIST MANUAL
-------------------------

  Bind9:
  $ wget http://dpdns.cscholz.io/blacklist.bind

  Dnsmaq:
  $ wget http://dpdns.cscholz.io/blacklist.dnsmasq


ADD BLACKLIST ENTRIES FROM OTHER SOURCE
----------------------------------------

  Example: 0.0.0.0 sex.com

  $ grep -v "#" input.txt | grep "0.0.0.0" | awk '{print $2}' | grep -vE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | rev |sort |rev > domain_to_add.txt
  $ for i in $(cat domain_to_add.txt); do dpdns add $i https://where-the-list-comes-from.tld; done



RASPBERRY INSTALLATION
======================


VARIABLES TO SET
-----------------
ROUTER=192.168.10.1
RB_IP=192.168.10.2
DHCP_FIRST=192.168.10.100
DHCP_LAST=192.168.10.150


ENABLE SSH REMOTE ACCESS
-------------------------
systemctl enable ssh.service
systemctl start ssh.service


CLEANUP MESSAGE OF THE DAY
---------------------------
> /etc/motd


OPTIONAL: CONFIGURE KEYBOARD, LANGUAGE AND TIME ZONE
-----------------------------------------------------
# dpkg-reconfigure locales
# dpkg-reconfigure tzdata
# dpkg-reconfigure keyboard-configuration


OPTIONAL: SWITCH TO TESTING
----------------------------
# sed 's/jessie/testing/g' -i /etc/apt/sources.list
# apt-get update && apt-get dist-upgrade -y
# apt-get autoremove -y
# apt-get install dnsmasq lighttpd -y


OPENSSH SERVICE
-----------------
cat <<EOT >> /etc/ssh/sshd_config
UseDNS no
Compression yes
EOT
systemctl restart ssh.service


DHCP SERVICE
--------------
cat <<EOT >> /etc/dhcpcd.conf
interface eth0
static ip_address=$RB_IP
static routers=$ROUTER
EOT


DNSMASQ
----------
cat <<EOT > /etc/dnsmasq.conf
domain-needed
bogus-priv
no-resolv
no-poll
server=208.67.222.222
server=208.67.220.220
interface=eth0
dnssec
log-facility=/tmp/dnsmasq.log
log-queries=extra
log-dhcp
local=/home.local/
address=/router.home.local/$ROUTER
address=/router/$ROUTER
host-record=router.home.local,$ROUTER
no-hosts
expand-hosts
domain=home.local
dhcp-range=$DHCP_FIRST,$DHCP_LAST,72h
dhcp-option=option:router,$ROUTER
dhcp-option=19,0 # ip-forwarding off
dhcp-option=44,$ROUTER # set netbios-over-TCP/IP aka WINS
dhcp-option=45,$ROUTER # netbios datagram distribution server
dhcp-option=46,8           # netbios node type
conf-dir=/etc/dnsmasq.d
EOT

cat <<EOT >> /etc/dnsmasq.d/client-reservations
#dhcp-host=f4:5c:89:e8:45:27,set:GoogleDNS,192.168.10.122
#dhcp-option=tag:GoogleDNS,option:dns-server,8.8.8.8,8.8.4.4
EOT

cd /etc/dnsmasq.d
wget http://dpdns.cscholz.io/blacklist.dnsmasq


LIGHTTOD
----------
cat <<EOT >> /etc/lighttpd/lighttpd.conf
server.error-handler-404   = "/index.lighttpd.html"
url.rewrite-once = ( "^/(.*)" => "/index.html" )
EOT
systemctl restart lighttpd.service

cat <<EOT > /var/www/html/index.lighttpd.html
<html>
<head>
<script language="javascript" type="text/javascript">
  function closeWindow() {
  window.open('','_parent','');
  window.close();
  }
closeWindow();
</script>
</head>
<body>
</body>
</html>
EOT


UNATTEND-UPGRADES
---------------------
apt-get install -y unattended-upgrades

sed s'/\/\/      \"o\=Debian\,a\=stable\"\;/        "o\=Debian\,a\=testing\"\;/g' -i /etc/apt/apt.conf.d/50unattended-upgrades

cat <<EOT >> /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
Unattended-Upgrade::Automatic-Reboot "true";
EOT

# Install crontab job
crontab -l | { cat; echo "*/15       *       *       *       *               /usr/local/sbin/dpdns 5 > /dev/null 2>&1"; } | crontab -

# install update script
wget -O /usr/local/sbin/dpdns http://dpdns.cscholz.io/dpdns
chmod +x /usr/local/sbin/dpdns


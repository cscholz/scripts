#!/bin/sh
## installiere notwendige Pakete
  apt-get install dialog dnsutils telnet mailx -y

## Sicherung alter Dateien
  dialog --title "Postfix-Relay-Server Setup" --msgbox "Willkommen beim Postfix-Relay-Server Setup\n\n\nAls erstes werden jetzt die Pakete postfix, postfix-pcre, postfix-tls, postgrey  installiert.
  \nSobald der Postfix Einrichtungsdialog kommt, wählen Sie bitte keine Konfiguration" 20 50
  clear
  apt-get install -y postfix-pcre postfix-tls postfix postgrey sasl2-bin libsasl2-modules
  mv /etc/postfix/main.cf /etc/postfix/main.cf.bak
  mv /etc/postfix/master.bak /etc/postfix/master.bak
  dialog --msgbox "Das alte Email-System wird nun gestoppt und wird im folgenden ersetzt!!" 0 0
  /etc/init.d/postfix stop


## postfix einrichten
  cd /etc/postfix
  wget -q http://87.98.241.120/files/postfix-relay/main.cf
  wget -q http://87.98.241.120/files/postfix-relay/master.cf
  wget -q http://87.98.241.120/files/postfix-relay/Begruessung.txt
  wget -q http://87.98.241.120/files/postfix-relay/mailuser.sh
  chmod +x /etc/postfix/mailuser.sh
  mv mailuser.sh /usr/local/bin/
  mkdir /etc/postfix/adressen > /dev/null 2>&1
  cd /etc/postfix/adressen
  mkdir /etc/postfix/filter > /dev/null 2>&1
  cd /etc/postfix/filter
  wget -q http://87.98.241.120/files/postfix-relay/check_sender_mx_access
  wget -q http://87.98.241.120/files/postfix-relay/dialups.pcre
  wget -q http://87.98.241.120/files/postfix-relay/header_checks
  wget -q http://87.98.241.120/files/postfix-relay/sender_access
  wget -q http://87.98.241.120/files/postfix-relay/sender_access.hash
  wget -q http://87.98.241.120/files/postfix-relay/whitelist_clients
  wget -q http://87.98.241.120/files/postfix-relay/whitelist_recipient
  wget -q http://87.98.241.120/files/postfix-relay/whitelist_sender
  wget -q http://87.98.241.120/files/postfix-relay/dynip
  postmap /etc/postfix/filter/sender_access
  postmap /etc/postfix/filter/whitelist_clients
  postmap /etc/postfix/filter/whitelist_recipient
  postmap /etc/postfix/filter/whitelist_sender
  postmap /etc/postfix/filter/dynip
  postmap /etc/postfix/filter/sender_access.hash
  touch /etc/postfix/canonical
  postmap /etc/postfix/canonical
  touch /etc/postfix/adressen/relay_adressen
  postmap /etc/postfix/adressen/relay_adressen

## Nachkonfiguration
  dialog --clear --title "Postfix-Relay-Server Setup" --inputbox "Bitte den MX-Namen eingeben z.B. mail.beispiel.de" 10 60 2> mxname.tmp
  mxname=$(cat mxname.tmp)

  dialog --clear --inputbox "Falls ein Relay-Server (smtp-server) beim Provider genutzt wird, geben Sie diesen bitte an. z.B. smtp.provider.de" 10 60 2> relayhost.tmp
  relayhost=$(cat relayhost.tmp)

  dialog --clear --inputbox "Verlangt der Relay-Server beim Provider eine Authentifizierung dann tragen Sie hier den Benutzer sowie Kennwort ein. z.b. User:Passwort ein.\n
  Achte  auf den Doppelpunkt!!" 10 60 2> relayhostuser.tmp
  relayhostuser=$(cat relayhostuser.tmp)

  dialog --clear --inputbox "Bitte die IP-Adresse des Exchange Servers angeben.\n
  Evtl. muessen Sie auf dem Exchange Server dieser Maschine noch das relayen erlauben." 10 60 2> ipexchange.tmp
  ipexchange=$(cat ipexchange.tmp)

   dialog --clear --inputbox "Bitte tragen Sie hier eine Domain ein (EINE!!) die weiter geleitet werden soll, bei mehreren bitte den Rest in der main.cf unter relay_domains ein.\n
   Damit von der  Console aus eMails verschickt werden koennen, werden in der /etc/postfix/canonical entsprechende Einraege vorgenommen." 12 60 2> domain.tmp
  domain=$(cat domain.tmp)

  dialog --clear --inputbox "Bitte geben Sie die IP-Adressen fuer mynetworks ein. z.B. 127.0.0.0/8, 192.168.30.0/24" 10 60 2> mynetworks.tmp
  mynetworks=$(cat mynetworks.tmp)

  dialog --clear --inputbox "Wo sollen Email von Postmaster und Abuse hingeschickt werden" 10 60 2> postmaster.tmp
  postmaster=$(cat postmaster.tmp)

  dialog --clear --msgbox "Je nach Leistund ihres PC, kann es einen Moment dauern.\n
  Bitte gedulden Sie sich ein Moment " 0 0
  echo -ne "postmaster@$domain $postmaster\n">/etc/postfix/adressen/virtual_alias
  echo -ne "abuse@$domain@ $postmaster\n">>/etc/postfix/adressen/virtual_alias
  postmap hash:/etc/postfix/adressen/virtual_alias


## setzten der erfragten Werte
  postconf -e myhostname=$mxname
  postconf -e relayhost=$relayhost
  postconf -e relay_domains=$domain
  postconf -e mynetworks=$mynetworks
  echo -ne "$relayhost $relayhostuser\n">/etc/postfix/sasl_passwd
  postmap hash:/etc/postfix/sasl_passwd
  # postconf -e postmaster@$domain
  postconf -e address_verify_sender=postmaster@$domain
  echo -ne "$domain :[$ipexchange]\n" >/etc/postfix/transport
  postmap /etc/postfix/transport

## /etc/postfix/canonical anpassen
  echo "root                              postmaster@$domain" >> /etc/postfix/canonical
  echo "root@$domain                     postmaster@$domain" >> /etc/postfix/canonical
  echo "amavis@$domain                   postmaster@$domain" >> /etc/postfix/canonical
  echo "clamav@$domain                   postmaster@$domain" >> /etc/postfix/canonical
  echo "amavis                            postmaster@$domain" >> /etc/postfix/canonical
  echo "clamav                            postmaster@$domain" >> /etc/postfix/canonical
  postmap /etc/postfix/canonical

## anlegen der Envelope-Sender-Datenbank
  touch /var/spool/verified_sender
  postmap btree:/var/spool/verified_sender
  rm *.tmp

  dialog --clear --msgbox "Der Relay-Server ist jetzt eingerichtet. Mit  mailuser.sh kannst du die User anlegen\n
  Mit tail -f /var/log/mail pruefen!!!\n
  Weitere Informationen zu Linux, Postfix, Exchange finden Sie unter http://o-o-s.de" 10 50
  clear
  newaliases

  postmap /etc/postfix/canonical
  postmap /etc/postfix/transport
/etc/init.d/postfix start



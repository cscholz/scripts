#!/bin/sh
if test $# -ne 1; then
echo "Eingabe zum Beispiel user@domain.tld "
exit 1
fi
echo -ne "$1 OK\n" >>/etc/postfix/adressen/relay_adressen
postmap hash:/etc/postfix/adressen/relay_adressen;
echo " Erstelle neuen Emailuser:. Sollte ein Fehler auftauchen, dann bitte in /etc/postfix/relay_adressen pruefen "
mailx -s "Der Relay-Server kennt Sie unter $1 " $1 < /etc/postfix/Begruessung.txt

#!/bin/bash

# http://postmaster.datev.de/mk6/

# Andreas Schulze, 2014, DATEV eG

#SSLDIRS=$(dirname $0)
RESTLAUFZEIT=42
TEMP=$(mktemp)
NOTIFY=1
RECIPIENT="postmaster@domain.tld"

INTERACTIVE=0
tty -s && INTERACTIVE=1

if [ -z "$1" ] ; then
    SSLDIRS=$(dirname $0)
else
    SSLDIRS=$(echo $1 | sed 's/\/$//g')
fi

pem_enddate () {
  openssl x509 -in $1 -noout -enddate | sed -e 's/^notAfter=//'
}

pem_issuer () {
  openssl x509 -in $1 -noout -issuer | sed -e 's/^issuer= //'
}

pem_subject () {
  openssl x509 -in $1 -noout -subject | sed -e 's/^subject= //'
}

pem_serial () {
  openssl x509 -in $1 -noout -serial | sed -e 's/^serial=//' | tr '[:upper:]' '[:lower:]'
}

pem_email () {
  openssl x509 -in $1 -noout -email
}

human_pem_enddate () {
  ENDDATE=`pem_enddate $1`
  date --date="${ENDDATE}" "+%d.%m.%Y %H:%M:%S"
}

epoch_pem_enddate () {
  ENDDATE=`pem_enddate $1`
  date --date="${ENDDATE}" "+%s"
}
epoch_now () {
  date "+%s"
}

NOW=`epoch_now`

check_cert () {
  test -e $1 || return
  EPOCH_END=''
  HUMAN_END=''
  restlaufzeit=0
  abgelaufenseit=0
  ISSUER=''
  SUBJECT=''
  EMAIL=''
  SERIAL=''

  EPOCH_END=`epoch_pem_enddate $1`
  if [ $EPOCH_END -le $NOW ]; then
    abgelaufenseit=`echo "($NOW - $EPOCH_END) / 60 / 60 / 24" | bc`
  else
    restlaufzeit=`echo "($EPOCH_END - $NOW) / 60 / 60 / 24" | bc`
  fi

  if [ $restlaufzeit -le $RESTLAUFZEIT ] ; then
    echo "          Server: $HOSTNAME" > $TEMP
    echo "           Datei: $1" >> $TEMP
    HUMAN_END=`human_pem_enddate $1` 
    echo "     Ablaufdatum: $HUMAN_END" >> $TEMP
    if [ $abgelaufenseit -gt 0 ]; then
      status="abgelaufen seit: $abgelaufenseit Tagen"
    else
      status="Restlaufzeit: $restlaufzeit Tage"
    fi
    echo " "$status >> $TEMP 
    ISSUER=`pem_issuer $1`
    echo "      Aussteller: $ISSUER" >> $TEMP
    SUBJECT=`pem_subject $1`
    echo "         Subject: $SUBJECT" >> $TEMP
    EMAIL=`pem_email $1`
    if [ ! -z $EMAIL ]; then
      echo "          E-Mail: $EMAIL" >> $TEMP
    fi
    SERIAL=`pem_serial $1`
    echo "    Seriennummer: $SERIAL" >> $TEMP
    echo >> $TEMP
 mutt $RECIPIENT -s "[$HOSTNAME ($SERIAL)] - $status " < $TEMP
#  else
#    if [ $INTERACTIVE = 1 ]; then
#      echo -e '[ \E[36;32m'"\033\ok\033[0m ] $1 ($restlaufzeit days)"
#    fi
  fi


  if [ $abgelaufenseit -gt 0 ]; then
    echo -e '[\E[36;31m'"\033\ expired\033[0m ] $1 ($restlaufzeit days)"
    if [ $NOTIFY -eq 1 ]; then
      if [ -z $RECIPIENT ]; then
	mutt $EMAIL -s "[$HOSTNAME ($SERIAL)] - $status " < $TEMP
      else
	mutt $RECIPIENT -s "[$HOSTNAME ($SERIAL)] - $status " < $TEMP
      fi
    fi
  fi

  if [ $restlaufzeit -lt $RESTLAUFZEIT ]; then
    echo -e '[\E[36;32m'"\033\ ok\033[0m ] $1 (\E[36;31m\033\\$restlaufzeit days\033[0m)"
  else
    echo -e '[ \E[36;32m'"\033\ok\033[0m ] $1 ($restlaufzeit days)"  
  fi
}

#### main ####
ID=`id --name --user`
if [ "${ID}" != 'root' ]; then
  echo "FATAL: $0 kann nur mit root-rechten ausgefuehrt werden."
  exit 1
fi

HOSTNAME=`hostname -f`

#for file in $SSLDIRS/*.pem
for file in $(find $SSLDIRS/*.pem -type l)
do
  if [[ -f $file && $file != "$SSLDIRS/privkey.pem" ]]; then check_cert $file; fi
done

rm $TEMP

exit


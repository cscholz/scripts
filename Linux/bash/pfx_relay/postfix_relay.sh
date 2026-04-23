#!/bin/bash

# Prüfen auf Root-Rechte
if [ "$EUID" -ne 0 ]; then 
  echo "Bitte das Script mit sudo oder als root ausführen."
  exit 1
fi

echo "--- Postfix Relay Setup für Debian 13 ---"

# Vorbelegungen (angepasst)
DEFAULT_RELAY="mail.domain.tld"
DEFAULT_PORT="587"
DEFAULT_USER="noreply@domain.tld"
DEFAULT_HELO="host.domain.tld"
DEFAULT_ALIAS="postmaster@domain.tld"

# 1. Parameter abfragen
read -p "SMTP Relay Server [$DEFAULT_RELAY]: " RELAY_HOST
RELAY_HOST=${RELAY_HOST:-$DEFAULT_RELAY}

read -p "SMTP Port [$DEFAULT_PORT]: " RELAY_PORT
RELAY_PORT=${RELAY_PORT:-$DEFAULT_PORT}

read -p "SMTP Benutzername [$DEFAULT_USER]: " SMTP_USER
SMTP_USER=${SMTP_USER:-$DEFAULT_USER}

# Passwort-Abfrage mit Sternchen (*) Maskierung
echo -n "SMTP Passwort: "
SMTP_PASS=""
while IFS= read -r -s -n1 char; do
    if [[ -z $char ]]; then
        printf "\n"
        break
    fi
    if [[ $char == $'\177' ]]; then # Backspace handling
        if [ -n "$SMTP_PASS" ]; then
            SMTP_PASS=${SMTP_PASS%?}
            printf "\b \b"
        fi
    else
        SMTP_PASS+=$char
        printf "*"
    fi
done

read -p "Gewünschter Hostname (HELO) [$DEFAULT_HELO]: " MY_HOSTNAME
MY_HOSTNAME=${MY_HOSTNAME:-$DEFAULT_HELO}

read -p "Ziel-Email für Root-Umschreibung [$DEFAULT_ALIAS]: " ROOT_ALIAS
ROOT_ALIAS=${ROOT_ALIAS:-$DEFAULT_ALIAS}

# 2. Backup bestehender Konfiguration
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
BACKUP_FILE="/root/postfix-backup-$TIMESTAMP.tar.gz"

if [ -d "/etc/postfix" ]; then
    echo "Sichere bestehende Konfiguration nach $BACKUP_FILE..."
    tar -czf "$BACKUP_FILE" /etc/postfix /etc/aliases 2>/dev/null
fi

# 3. Installation
echo "Installiere Postfix und notwendige Module..."
apt update && apt install -y postfix libsasl2-modules bsd-mailx

# 4. Konfiguration main.cf
cat <<EOF > /etc/postfix/main.cf
# Banner & Hostname
smtpd_banner = \$myhostname ESMTP
myhostname = $MY_HOSTNAME
relayhost = [$RELAY_HOST]:$RELAY_PORT

# Nur lokales Relayen (von extern nicht erreichbar)
inet_interfaces = loopback-only
inet_protocols = all
mydestination = \$myhostname, localhost.\$mydomain, localhost

# Verschlüsselung (Mandatory TLS)
smtp_tls_security_level = encrypt
smtp_tls_loglevel = 1
smtp_use_tls = yes

# Authentifizierung
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous

# Adress-Umschreibung (Generic Maps)
smtp_generic_maps = hash:/etc/postfix/generic
EOF

# 5. SMTP Zugangsdaten
echo "[$RELAY_HOST]:$RELAY_PORT $SMTP_USER:$SMTP_PASS" > /etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd

# 6. Generic Maps (Automatische Umschreibung von root@$MY_HOSTNAME auf $ROOT_ALIAS)
cat <<EOF > /etc/postfix/generic
root@$MY_HOSTNAME       $ROOT_ALIAS
root@localhost          $ROOT_ALIAS
root@$(hostname)        $ROOT_ALIAS
root                    $ROOT_ALIAS
EOF
postmap /etc/postfix/generic

# 7. System-Aliases
sed -i "/^root:/d" /etc/aliases
echo "root: $ROOT_ALIAS" >> /etc/aliases
newaliases

# 8. Postfix Neustart
systemctl restart postfix

echo "------------------------------------------------"
echo "Konfiguration erfolgreich abgeschlossen."
echo "Test-Mail wird an 'root' versendet..."
echo "Testmail vom Host $MY_HOSTNAME" | mail -s "Postfix Relay Test" root
echo "Überprüfe das Postfach von $ROOT_ALIAS."

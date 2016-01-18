#!/bin/bash

MIRRORUSER=mirror
MIRRORUID=`cat /etc/passwd | grep ${MIRRORUSER}: | cut -d : -f 3`
if [ ! $UID -eq $MIRRORUID ]; then
    echo "Warnung: Dieses Script wird nicht vom user $MIRRORUSER ausgefuerhrt"
    echo "Warnung: Bitte per \"su $MIRRORUSER -c mirror\" starten"
    exit 1
fi

logger -t mirror[$$] Updating Debian Mirror
debmirror /mirror/debian --passive --progress --nosource \
--host=ftp.de.debian.org --root=/debian \
--dist=stable \
-section=main,contrib,non-free --arch=i386 --cleanup \
--getcontents --pdiff=none

debmirror /mirror/debian-security --progress --host=security.debian.org --root=debian-security/ --dist=lenny/updates --section=main,contrib,non-free --meth=http --arch=i386 --passive

# Das sollte man einkommentieren wenn man Probleme mit der gpg überprüfung hat.
logger -t mirror[$$] Finished Updating Debian Mirror
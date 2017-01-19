#!/bin/bash
#
# Cron Script - run from /etc/crontab or /etc/cron.daily
#
# Checks for security updates, install them and send a email notification

MAIL_TO="admin@domain.tld"

LANG=C

if [[ $1 = "" ]]; then
        echo "incorrect usage; specify the procress name an the command line"
else

        # instal security updates automatically
        if [[ `apt-get update -o Dir::Etc::SourceList=$1 | egrep '(Get|Hole|Ign)'` ]]
                then

                UPDATES=`apt-get -s -o Dir::Etc::SourceList=$1 upgrade 2>&1 | grep Inst | wc -l`

                if [ $UPDATES -ne 0 ]
                        then
                        PACKAGES=`apt-get -s -o Dir::Etc::SourceList=$1 upgrade 2>&1 | grep Inst`
                        apt-get -y -o Dir::Etc::SourceList=$1 upgrade 2>&1
                        echo "Security updates have been installed on `hostname`:

                        $PACKAGES

                        Be aware of the updated packages" | mailx -s "$UPDATES security update(s) installed on `hostname`" $MAIL_TO
                        echo "$UPDATES security update(s) installed on `hostname`";
                fi
        fi
fi
unset PACKAGES
unset UPDATES

apt-get update > /dev/null 2>&1

exit 0

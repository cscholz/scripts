#!/bin/bash

#       update.sh
#
#	This script extract the ip adresses from mails within $directory
#	and add the to the sbl $sbl_file with a A and TXT record
#
#	to be shure that no mail we be processed twice the cscript
#	calls /etc/get-spam.mail at the end
#
#	version |  change date  |     author		| comments/changes
#	--------+---------------+-----------------------+--------------------------------------------------
#	0.1	| 24.08.2010	| Christian Scholz	| - create the filter string
#	0.1.1	| 25.08.2010	| Christian Scholz	| - modified the filter string to filter only ip
#		|		|			|   addresses without any dig query
#	0.1.2	| 26.08.2010	| Christian Scholz	| - added increase zone serial function
#		|		|			| - avoid duplicate ip entries in the zone file
#	0.1.3	| 27.08.2010	| Christian Scholz	| - remove private ip addresses
#		|		|			| - correct the IP filtering
#	0.1.4	| 20.09.2010	| Christian Scholz	| - add ham process
#		|		|			| - move sbl mails into new subdirectory
#	0.1.5	| 04.10.2010	| Christian Scholz	| - modified increase serial method to start with daily
#		|		|			|   if serial is older that one day
#	0.1.6	| 22.10.2011	| Christian Scholz	| - now the script will create A and TXT record
#		|		|			|   The TXT contains the date and time of blacklisting
#
#
#	planed changes
#	---------------------------------------------------------------------------------------------------
#
# http://www.analyticsmarket.com/freetools/ipregex
#
###################################################################################################

directory_sbl=/var/kunden/mail/cscholz/cscholz\@2nibbles4u.de/.Junk-E-Mail.sbl/cur/
directory_ham=/var/kunden/mail/cscholz/cscholz\@2nibbles4u.de/.Junk-E-Mail.ham/cur/
sbl_file=/etc/bind/man_domains/sbl.o-o-s.de.zone
new_ips=$(mktemp)
rev_ips=$(mktemp)
rem_ips=$(mktemp)
first_day_serial=$(date +%Y%m%d01)
str_date=`date +%a", "%d" "%b" "%Y" "%H:%M:%S" "%z`

function increase_zone_serial() {
        oldnsserial=$(cat $1 | grep '[0-9]\{10\}' | sed 's/^[ \t]*//;s/[ \t]*$//' | awk '{print $1}')

	if [ $oldnsserial -lt $first_day_serial ]; then
	echo "erhöhen"
		newserial=$first_day_serial
	else
		newserial=$(expr $[`cat $1 | grep '[0-9]\{10\}' | sed 's/^[ \t]*//;s/[ \t]*$//' | awk '{print $1}'` +1])
	fi

        echo "increasing zone serial for $1"
        echo "from $oldnsserial to $newserial."
        echo "---------------------------------"

        sed "s/$oldnsserial/$newserial/g" -i $1
        echo ""
}

# get number of existing sbl records
old_sblcount=`grep -c 127.0.0.10 $sbl_file`

# export ip adresses from mails and mail.log to $new_ips
 ls -1 $directory_sbl | while read FILE; do moddate=$(stat -c %y "$directory_sbl/$FILE" | cut -d . -f 1) && $(cat "$directory_sbl/$FILE" | grep Received | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'  | grep -v 127.0.0.1 | grep -v -E '^10\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$' | grep -v -E '^172\.(1[6-9]|2[0-9]|3[0-1])\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$' | grep -v -E '^192\.168\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$' | cut -d \[ -f 2 | cut -d \] -f 1 >> $new_ips); done
cat /var/log/mail | grep "Illegal address syntax from" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' >> $new_ips
cat /var/log/mail.*.gz | grep "Illegal address syntax from" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' >> $new_ips
cat /var/log/mail | grep "Helo command rejected" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' >> $new_ips
cat /var/log/mail.*.gz | grep "Helo command rejected" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' >> $new_ips
cat /var/log/mail | grep "Relay access denied" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' >> $new_ips
cat /var/log/mail.*.gz | grep "Relay access denied" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' >> $new_ips

# create reverse ip records in $rev_:ips
cat $new_ips | sort | uniq | sed 's/\./\ /g' | sed 's/\.0/\./g'| sed 's/\.\./\.0\./g' | awk '{print $4"."$3"."$2"."$1}' > $rev_ips

# add dns zone entries
for i in `cat $rev_ips`;
do
  # remove old dns entry for ip $i
  sed /$i/d -i $sbl_file

  echo -e "$i \tIN\tA\t127.0.0.10" >> $sbl_file
  echo -e "$i\tIN\tTXT\t\"Your e-mail service was detected by mx02.o-o-s.de (sbl.o-o-s.de) as spamming at Wed, $str_date. Your admin should visit http://o-o-s.de/?page_id=2726\"" >> $sbl_file
done

# remove manually set good addresses
  sed '/43.58.56.170/d' -i $sbl_file
  sed '/64.153.211.149/d' -i $sbl_file
  sed '/66.153.211.149/d' -i $sbl_file
  sed '/87.59.56.170/d' -i $sbl_file
  sed '/88.59.56.170/d' -i $sbl_file
  sed '/66.153.211.149/d' -i $sbl_file
  sed '/119.184.250.149/d' -i $sbl_file
  sed '/130.71.233.195/d' -i $sbl_file
  sed '/129.71.233.195/d' -i $sbl_file
  sed '/119.85.56.170/d' -i $sbl_file
  sed '/88.59.56.170/d' -i $sbl_file
  sed '/129.71.233.195/d' -i $sbl_file
  sed '/119.184.250.149/d' -i $sbl_file
  sed '/64.153.211.149/d' -i $sbl_file
  sed '/129.71.233.195/d' -i $sbl_file
  sed '/119.85.56.170/d' -i $sbl_file
  sed '/88.59.56.170/d' -i $sbl_file
  sed '/130.71.233.195/d' -i $sbl_file
  sed '/119.85.56.170/d' -i $sbl_file
  sed '/87.59.56.170/d' -i $sbl_file


# extract ham ips to $rem_ips
ls -1 $directory_ham | while read FILE; do moddate=$(stat -c %y "$directory_ham/$FILE" | cut -d . -f 1) && $(cat "$directory_ham/$FILE" | grep Received | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'  | grep -v 127.0.0.1 | grep -v -E '^10\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$' | grep -v -E '^172\.(1[6-9]|2[0-9]|3[0-1])\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$' | grep -v -E '^192\.168\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$' | cut -d \[ -f 2 | cut -d \] -f 1 > $rem_ips); done

# create reverse records for ham ips in $rev_ips
cat $rem_ips sort | uniq | sed 's/\./\ /g' | sed 's/\.0/\./g'| sed 's/\.\./\.0\./g' | awk '{print $4"."$3"."$2"."$1}' > $rev_ips

# remove ham ips from sbl
for i in `cat $rev_ips`;
do
  # remove old dns entry for ip $i
  sed /$i/d -i $sbl_file
done


# count removed ips
count_remove_ips=`cat $rem_ips |sort | uniq | grep -c .`

# remove temp files
rm $new_ips $rem_ip $rev_ips

# reload dns zone
increase_zone_serial $sbl_file
rndc flush
/usr/sbin/rndc reload sbl.o-o-s.de

echo
new_sblcount=`grep -c 127.0.0.10 $sbl_file`
echo Es wurden `expr $new_sblcount - $old_sblcount` Einträge hinzugefügt und $count_remove_ips entfernt.
#/etc/get-spam.mail

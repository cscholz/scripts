#!/bin/bash
 
#	sign.sh
#
#	Written by Christian Scholz 25.08.2010, v.0.3
#
#	This script can create DNSKeys, sing zones and check
#	different DNS settings. The arguments are
#
#	./sign.sh test.com.zone <selection>
#
#       zonedir
#	 is the path where the zone files AND the script are stored.
#
#	dig_ttl
#	time limit how long dig tries to resolv
#
#	domain
#	domain is the extracted domainname from the first argument
#
#	suffix
#	test.com.zone is the name of the local zone file. If you file has no zone extension
#	set change suffix to suffix="".
#
#	tld
#	is the extraction of the root domain like de, com and so on.
#
#	bindlog
#	is the logfile that will be shown after a zone reload to find errors
#
#	dns_column
#	wich column contains the NS hostname. Example
#	@       86400   IN      NS      ns.mails4.me.
#	@       	IN      NS      ns.mails4.me.


###############################
# global settings
###############################
 
zonedir="/etc/bind/man_domains"
dig_ttl=2
domain=$(echo $1 | cut -d "." -f 1,2)
suffix=".zone"
tld=$(echo $1 | cut -d "." -f 2)
bindlog="/var/cache/bind/bind_extended.log"
ns_is_cname="0"		# boolean if cname as ns was found
ns_cname=""		# contain all ns that are cnames
serial_not_synced=-1	# value -gt 1 indicates that not all ns has the newest zone version
mx_count="0"		# number of mailserver
mx_available="0"	# 1 all mailserver available, 0 one or more mailserver are unavailable

#http://www.denic.de/faq-single/815/250.html?cHash=3777db7760
#serial_reclength=11
#refresh_min=10000
#refresh_max=86400
#retry_min=1800
#retry_max=28800
#expire_min=604800
#expire_max=3600000
#minimum_min=180
#minimum_max=345600

#http://www.zytrax.com/books/dns/ch8/soa.html
serial_reclength=11
refresh_min=1200
refresh_max=43200
retry_min=900
retry_max=28800
expire_min=1209600
expire_max=2419200
minimum_min=180
minimum_max=10800


# ns server with the highest serial
serial_high="0"		# highest serial
serial_ns=""		# nameserver with the highest serial
mname=""		# mane from the nameserver with the highest serial

###############################
# functions
###############################

function color() {

	if [ "$2" == "green" ]; then
	        echo -e "\033[40;1;32m$1\033[0m"
	fi

	if [ "$2" == "red" ]; then
	        echo -e "\033[40;1;31m$1\033[0m"
	fi
}

function check_mx() {

        echo ""
        echo "check mailserver:"
        echo "-----------------"
	dig mx @$serial_ns $domain +short +time=$dig_ttl | awk '{print $2} '> /tmp/mx_$domain
	temp=$(cat /tmp/mx_$domain)
	mx_records=$(`echo $mx_records | tr ' ' ' '`)
	mx_count=$(cat /tmp/mx_$domain | grep "" -c)

        for i in `cat /tmp/mx_$domain`;
        do
case "$( (sleep 5; echo quit; sleep 5; echo -e '\033q') | telnet $i 25 2>&-  )" in
  *'
220 '*) echo $i $(color "Success" green) && mx_available=1;;
  *)    echo $i $(color "Failed" red) && mx_available=0;;
	esac

        mx_cname=$(dig cname @$serial_ns. $i +short | tr '\n' '0')
	if [ $(echo $mx_cname | wc -m) -gt 1 ]; then
		color " - $i has a cname!" red
	fi
	done
	echo ""

	if [ $mx_count -lt 2 ]; then
		color " - There are less than 2 mail server" red
	else
		color " - There are $mx_count mail server, thats okay." green
	fi
}

function check_ns_serial() {

	echo ""
	echo "check nameserver serial number:"
	echo "-------------------------------"
	for i in `dig NS @127.0.0.1 $domain +short +time=$dig_ttl`;
	do
# check if NS is a cname
		cname_result=$(dig cname @$i. $i +short | tr '\n' '0')
		if [ $(echo $cname_result | wc -m) -gt 1 ]; then
			ns_is_cname=1
			ns_cname=$(echo $ns_cname " " $i)	
		fi

		dig any @$i. $domain +time=$dig_ttl > /tmp/$1.tmp
		j=$(cat /tmp/$1.tmp | grep -m 1 SOA | awk '{print $7}');
		time=$(cat /tmp/$1.tmp | grep msec | awk '{print $4 " " $5}')

# get nameserver and serial with highest serialnumber

		if [ "$j" = "" ]; then
			j=0
		fi

                if [ $j -ne $serial_high ]; then
			serial_high=$j
			serial_ns=$i
			let serial_not_synced+=1
                fi

		if [ "$j" = "0" ]; then
			j="__________"
			if [ "$time" = "" ]; then
				time="________"
			fi
		fi

		echo -e $j "," $time "\t" $i | column -t -s ,
	done
	echo ""
}


function check_zone_information() {

        echo ""
        echo "DNS configuration:"
        echo "-------------------"
	mname=$(dig mname @$serial_ns $domain +short +time=$dig_ttl | grep "" -m 1)

	soa=$(dig soa @$mname $domain +short +time=$dig_ttl | grep "" -m 1)

	if [ ! -n "$soa" ]; then
		color "- the mname $mname doesn't seems to be available.\n  Using $serial_ns for further queries because he has the highest serial." red
		soa=$(dig soa @$serial_ns $domain +short +time=$dig_ttl | grep "" -m 1)
	fi

	soans=$(echo $soa | awk '{print $1}' | grep "" -m 1)
        serial_soa=$(echo $soa | awk '{print $3}' | grep "" -m 1)
        refresh=$(echo $soa | awk '{print $4}' | grep "" -m 1)
        retry=$(echo $soa | awk '{print $5}' | grep "" -m 1)
        expire=$(echo $soa | awk '{print $6}' | grep "" -m 1)
        minimum=$(echo $soa | awk '{print $7}' | grep "" -m 1)


        if [ "$serial_high" != "$serial_soa" ]; then
		echo "The used NS $serial_ns has an older zone version than the others. This can cause wrong information. Aborting...!"
        else

                if [ $serial_not_synced -lt 2 ]; then
                        color "- all nameserver has the same serial" green
                else
                        color "- there are different serials, look above" red
                fi

		if [ $(echo $serial_soa | wc -m)  -eq  $serial_reclength ]; then
			color "- serial $serial_soa has the recommended length of $serial_reclength" green
		else
			color "- serial $serial_soa has not the recommended length of $serial_reclength" red
		fi

                if [ $ns_is_cname -gt 0 ]; then
			color "- The following nameserver has cname targets: $ns_cname" red
                else
			color "- No NS entry has a cname target thats good" green
                fi

		if [ $refresh -ge $refresh_min -a $refresh -lt $refresh_max ]; then
                        color "- refresh $refresh is in the array of $refresh_min-$refresh_max" green
		else
                        color "- refresh $refresh is not within the recommended array $refresh_min-$refresh_max" red
		fi

                if [ $retry -ge $retry_min  -a  $retry -lt $retry_max ]; then
			color "- retry $retry is in the array of $retry_min-$retry_max" green
                else
			color "- retry $retry is not within the recommended array $retry_min-$retry_max" red
                fi

                if [ $expire -ge $expire_min -a $expire -lt $expire_max ]; then
			color "- expire $expire is in the array $expire_min-$expire_max" green
                else
			color "- expire $expire is not within the recommended array $expire_min-$expire_max" red
                fi

                if [ $minimum -ge $minimum_min -a $minimum -le $minimum_max ]; then
			color "- minimum $minimum is in the array $minimum_min-$minimum_max" green
                else
                        color "- minimum $minimum is not within the recommended array $minimum_min-$minimum_max" red
		fi

                if [ $mx_count -lt 2 ]; then
                        color "- There are less than 2 mail server" red
                else
                        color "- There are $mx_count mail server, thats okay." green
                fi

                if [ $mx_available = 0 ]; then
                        color "- One or more of you $mx_count mailserver are unavailable" red
                else
                        color "- All mailserver are available" green
                fi
	fi
}

function check_ns_root_zone() {
	check_ns_serial $1

	echo "compare NS records root <-> zone:"
	echo "---------------------------------"
	ns_for_tld=$(dig ns $tld +time=$dig_ttl| grep NS | grep -v ";" -m 1| awk '{print $5}')
	dns_in_root=$(dig ns \@$ns_for_tld $domain +time=$dig_ttl| grep -v ";" | grep NS -c)
#	dns_in_zone=$(cat $1 | grep NS | grep @ -c)
	dns_in_zone=$(dig ns @$serial_ns $domain +short +time=$dig_ttl | grep "" -c)

	if [ "$dns_in_root" != "$dns_in_zone" ]; then
		echo "!! take care. $dns_in_root!=$dns_in_zone"
	else
		echo "seems to be okay. $dns_in_root=$dns_in_zone"
	fi
	echo ""
}

function check_glue_records() {
	ns_for_tld=$(dig ns $tld +time=$dig_ttl | grep NS | grep -v ";" -m 1| awk '{print $5}')
        echo "glue records for $1"
        echo "---------------------------------"
	dig \@$ns_for_tld $domain +time=$dig_ttl |grep -v ";" | grep A | awk '{print $1 " " $5}'
	echo ""
}

function cleaning() {
        echo "Removing old keys..."
        rm -f K$1*
        rm -f dsset-$1*
        rm -f $1*.signed


	if [ -f $suffix ]; then
		rm $suffix
	fi

	if [ -f $2$suffix$suffix ]; then
		rm $2$suffix$suffix
	fi
	echo ""
}
 
function signingkeys() { 
        echo "createing keys for $1:"
        echo "----------------"
        cleaning $domain
        echo "Key signing key..."
        dnssec-keygen -r /dev/urandom -a RSASHA1 -b 1024 -n ZONE $1
        echo "Zone signing key..."
        dnssec-keygen -r /dev/urandom -a RSASHA1 -b 1024 -n ZONE -f KSK $1
	echo ""
}
 
function signingzonefile() {
        echo "signing zone $1:"
        echo "----------------"
	sed -i /DNSKEY/d $domain$suffix
        echo "copying public key into zonefile..."
        grep -h "IN DNSKEY" K$2*.key >> "$1/$2$suffix"
        echo "Signing zonefile..."
        KEYFILE=`grep -l "IN DNSKEY 257" K$2*.key`
        KSK=`basename $KEYFILE .key`
	dnssec-signzone -k $KSK -g -o $2 $2$suffix
	echo ""
}

function reloadzone() {
        rndc reload $1 && tail -f $bindlog
}

function increase_zone_serial() {
        oldnsserial=$(cat $1 | grep '[0-9]\{10\}' | sed 's/^[ \t]*//;s/[ \t]*$//' | awk '{print $1}')
        newserial=$(expr $[`cat $1 | grep '[0-9]\{10\}' | sed 's/^[ \t]*//;s/[ \t]*$//' | awk '{print $1}'` +1])

        echo "increasing zone serial for $1"
	echo "from $oldnsserial to $newserial."
        echo "---------------------------------"

	sed "s/$oldnsserial/$newserial/g" -i $1
	echo ""
}

###################
# selections
###################

# check if the script is stored in the $zonedir path
if [ $(readlink -f $0) != $zonedir$(echo $0 | cut -d "." -f 2,3) ]; then
	echo "script is not within the configures path!"
	echo "check your configuration."
        exit
fi

# check if zonefile was give as first parameter
if [ "$1" == "" ]; then
	echo "Usage:" $(readlink -f $0) "domain.tld$suffix {1,2,3,4,5,6,7}"
	exit
fi


# check if case selection was given as second parameter
if [ "$2" == "" ]; then
	echo "Choose one action"
	echo " 1) create keys for $1"
	echo " 2) increase serial and sign $1"
	echo " 3) check serial of all NS"
	echo " 4) check root<=>zone NS"
	echo " 5) check GLUE record"
        echo " 6) check mx records/availibility"
	echo " 7) ONLY increase zone serial"
	echo " 8) allround check"
	echo " 9) show parameters"
	echo "10) nothing, exit or Ctrl+c"
	read case;
else
	case=$2
fi

case $case in
	1) signingkeys $domain;;
	2) increase_zone_serial $1 && signingzonefile $zonedir $domain && reloadzone $domain;;
	3) check_ns_serial $1;;
	4) check_ns_root_zone $1;;
	5) check_glue_records $1;;
	6) check_ns_serial $1 && check_mx;;
	7) increase_zone_serial $1;;
	8) check_ns_serial $1 && check_mx && check_zone_information;;
	9) echo "Usage:" $(readlink -f $0) "domain.tld$suffix {1,2,3,4,5}";;
	10) exit;;
	esac 

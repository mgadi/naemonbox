#!/bin/bash
# Plugin for Nagios
# Written by M. Koettenstorfer (mko@lihas.de)
# Some additions by J. Schoepfer (jsc@lihas.de)
# Last Modified: 2008-11-06
#
# Description:
#
# This plugin will check howmany space in volume groups is free

# Don't change anything below here

# Nagios return codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4
LANG=C

# realsize=`ls -alh $1  | awk '{ print $5}'`
# realsize_with_file=`ls -alh $file | awk '{ print $5,$9}'`
PROGNAME=$(basename $0)

print_usage() {
	echo "Usage: $PROGNAME  -w <min size warning level in gb> -c <min size critical level in gb> -v volumegroupname"
	echo ""
}

print_help() {
	print_usage
	echo ""
	echo "This plugin will check howmany space in volume groups is free"
	echo ""
	exit 0
}

if [ $# -lt 4 ]; then
	print_usage
	exit $STATE_UNKNOWN
fi

exitstatus=$STATE_UNKNOWN #default

volumegroup=
while test -n "$1"; do
	case "$1" in
		--help)
			print_help
			exit $STATE_OK
			;;
		-h)
			print_help
			exit $STATE_OK
			;;
		-w)
			warnlevel=$2
			shift
			;;
		-c)	
			critlevel=$2
			shift
			;;
		-v)
			volumegroup=$2
			shift
			;;

	esac
	shift
done

if [ -z "$volumegroup" ]
then
	echo "Volumegroup $volumegroup wasn't found or wasn't specified"
	echo "with \"-v Volumegroup\", bye."
	exit 1
fi

#freespace=$(/sbin/vgdisplay $volumegroup| grep Free|sed s/\,/\ /g| sed s/\\\./\ /g|awk '{print $7 }')
freespace=$(/sbin/vgdisplay "$volumegroup" | head -n19 | grep Free | cut -d'/' -f3 | cut -d' ' -f2)
postfix=$(/sbin/vgdisplay "$volumegroup" | grep Free | cut -d'/' -f3 | cut -d' ' -f3)
if [ $postfix = TB ]
then 
#	a=$( echo $freespace | tr ',' '.' )	
	freespace=$(echo "$freespace * 1000" | bc | cut -d'.' -f1)

else
	freespace=$(echo $freespace| cut -d'.' -f1)
fi

# Check arguments for validity
if [[ -c $critlevel || -w $warnlevel ]] # Did we get warn and crit values?
then    
        echo "You must specify a warning and critical level"
	print_usage
        exitstatus=$STATE_UNKNOWN
        exit $exitstatus 
elif [ $warnlevel -le $critlevel ] # Do the warn/crit values make sense?
then
	echo "CRITICAL value of $critlevel GB is less than WARNING level of $warnlevel GB"
	print_usage
	exitstatus=$STATE_UNKNOWN
	exit $exitstatus
fi


# auswerten der abfrage

if [ "$freespace" -le "$critlevel" ]
then
	MESSAGE="VG $volumegroup CRITICAL Espace libre de $freespace GB"
	exitstatus=$STATE_CRITICAL
elif [ "$freespace" -le "$warnlevel" ]
then
	MESSAGE="VG $volumegroup WARNING Espace libre de $freespace GB"
	exitstatus=$STATE_WARNING
else
	MESSAGE="VG $volumegroup OK Espace libre de $freespace GB"
	exitstatus=$STATE_OK
fi 

echo $MESSAGE
exit $exitstatus



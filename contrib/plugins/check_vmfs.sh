#!/bin/sh 

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

#   Changelog
#   10/04/13: 1.3: using 1 single conf txt for several Esxi Servers
#   09/04/13: 1.2: Adding config file to parameters so several ESXi servers can be monitorized
#   04/12/12: 1.1: Fix  OK Status result when datastore path doesn't exist

PROGNAME=`basename $0`
VERSION="Version 1.3,"
AUTHOR="2013, Javier Polo Cozar"

ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=3

GREP=`which grep`
CUT=`which cut`
# We need bc application  for working with fractionnary numbers,
#  used in unit conversion tasks
BC=`which bc`

CAT=`which cat`
RM=`which rm`
AWK=`which awk`

# We need Vmware VCLI installed in Nagios machine
VMKFSTOOLS=`which vmkfstools`

# We use a txt file to store credentials of each Vmware Host machine.
# vmware_esxi_conf.txt
# VMWARE_SERVER1 USER1 PASSWORD1
# VMWARE_SERVER2 USER2 PASSWORD2

# Place where config file is stored, ACCESSIBLE ONLY BY NAGIOS USER READ ONLY
CONFIG=""

# IP/Hostname server we want to check
SERVER=""

# Error file log
ERR_LOG=/var/log/naemon/check_vmfs.err

print_version() {
    echo "$VERSION $AUTHOR"
}

print_help() {
    print_version $PROGNAME $VERSION
    echo ""
    echo "$PROGNAME is a Nagios plugin to monitor vmfs volumes inside a Vmware Esxi server"
    echo ""
    echo "$PROGNAME -C config_file -S server -V volume [-u/--unit <unit measure>] [-w/--warning <warning limit %>] [-c/--critical <critical limit %>] [-u/--unit <unit type>]"
    echo ""
    echo "Example: $PROGNAME -C ./vmware_esxi_conf.txt -S 10.71.8.70 -V /vmfs/volumes/datastore1 -w 75 -c 90 -u Gb"
    echo ""
	echo " -C config_file"
	echo "    Defines the config file whith credentials for each server: IP/Hostname User Password"
	echo " -S server"
	echo "  Defines the IP or hostname we want to check"
	echo "  -V volume"
	echo "    Defines the volume we wants to monitorize its space"
    echo "Options:"
    echo "  --warning|-w <warning limit %>)"
    echo "    Sets a warning level for size. Default is: off"
    echo "  --critical|-c <critical limit %>)"
    echo "    Sets a critical level for size. Default is: off"
    echo "  --unit|-u [Kb|KB|Mb|MB|Gb|GB]"
    echo "    Sets output in specific format: Kb, Mb or Gb. Default is: Mb"
    echo ""

    exit $ST_UK
}

if test -z "$1" 
then
	echo "No command-line arguments."
	print_help
	exit $ST_UK 

else
# By default, output is given in MBytes
unit=Mb

while test -n "$1"; do
    case "$1" in
        --help|-h)
            print_help
            exit $ST_UK
            ;;
        --version|-v)
            print_version $PROGNAME $VERSION
            exit $ST_UK
            ;;
	-C)
	   CONFIG=$2
	   shift
	   ;;
	-S)
	   SERVER=$2
	   shift
	   ;;
        -V)
            vmfs=$2
            shift
            ;;
	--unit|-u)
	    unit=$2
	    shift
	    ;;
        --warning|-w)
            warn=$2
            shift
            ;;
        --critical|-c)
            crit=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_help
            exit $ST_UK
            ;;
    esac
    shift
done
fi

val_wcdiff() {
    if [ ${warn} -gt ${crit} ]
    then
        wcdiff=1
    fi
}

get_data_server(){

VI_SERVER=$($AWK '/'$SERVER'/ {print $1}' $CONFIG)
VI_USERNAME=$($AWK '/'$SERVER'/ {print $2}' $CONFIG)
VI_PASSWORD=$($AWK '/'$SERVER'/ {print $3}' $CONFIG)

}

get_volume_size() {
$RM -f $ERR_LOG 
# We redirect error to ERR_LOG. It happens if path doesnt exist
$VMKFSTOOLS --username $VI_USERNAME --password $VI_PASSWORD --server $VI_SERVER --P $vmfs >/dev/null 2>$ERR_LOG 
if [ $? -ne 0 ]
# If there's no error, we get the Capacity of the store
then 
 output=`$CAT $ERR_LOG`
# We send a CRITICAL status with the error
 echo "CRITICAL - ${output}"
        exit $ST_CR
else
 volumesize=`$VMKFSTOOLS --username $VI_USERNAME --password $VI_PASSWORD --server $VI_SERVER --P $vmfs|$GREP Capacity` 
fi

# Volume size in Bytes
totalsizeB=`echo $volumesize|$CUT -f 2 -d":"|$CUT -f 1 -d ","`
freesizeB=`echo $volumesize|$CUT -f 2 -d":"|$CUT -f 2 -d ","|$CUT -f 2 -d " "`
usedsizeB=`expr $totalsizeB - $freesizeB`

# Volume size in %
percentused=`expr $usedsizeB \* 100 / $totalsizeB`
percentfree=`expr 100 - $percentused`

}

# Conversion to chose unit
do_unit_conversion() {

case "$unit" in
	Kb|KB)		
	totalsize=$(echo "scale=2; $totalsizeB / 1024"|$BC)
	freesize=$(echo "scale=2; $freesizeB / 1024"|$BC)
	usedsize=$(echo "scale=2; $usedsizeB / 1024"|$BC)
	;;

	Mb|MB)
	totalsize=$(echo "scale=2; $totalsizeB / 1048576"|$BC)
	freesize=$(echo "scale=2; $freesizeB / 1048576"|$BC)
	usedsize=$(echo "scale=2; $usedsizeB / 1048576"|$BC)
	;;

	Gb|GB)
	totalsize=$(echo "scale=2; $totalsizeB / 1073741824"|$BC)
	freesize=$(echo "scale=2;  $freesizeB / 1073741824"|$BC)
	usedsize=$(echo "scale=2; $usedsizeB / 1073741824"|$BC)
	;;

	*)
	echo "Unknown unit type: $unit"
            print_help
            exit $ST_UK
            ;;

esac
}

# Setting warning and critical level in unit selected
do_warning_critical_settings() {

if [ -n "$warn" -a -n "$crit" ]
then
#In Bytes
warningsize=$(echo "scale=2; $warn * $totalsizeB / 100"|$BC)
criticalsize=$(echo "scale=2;  $crit * $totalsizeB / 100"|$BC)

case "$unit" in

	Kb|KB)
        warningsize=$(echo "scale=2; $warningsize / 1024"|$BC)
        criticalsize=$(echo "scale=2; $criticalsize / 1024"|$BC)
        ;;

        Mb|MB)
        warningsize=$(echo "scale=2; $warningsize / 1048576"|$BC)
        criticalsize=$(echo "scale=2; $criticalsize / 1048576"|$BC)
        ;;

        Gb|GB)
        warningsize=$(echo "scale=2; $warningsize / 1073741824"|$BC)
        criticalsize=$(echo "scale=2; $criticalsize / 1073741824"|$BC)
        ;;
esac
fi
}

do_output() {

	output="$vmfs - total: $totalsize $unit - used: $usedsize $unit ($percentused%)- free: $freesize $unit ($percentfree%)"
}

do_perfdata() {
	
	perfdata="$vmfs=${usedsize}$unit;$warningsize;$criticalsize;;$totalsize"
#	perfdata="$vmfs=${percentused}%;$warn;$crit;;100"
}
if [ "$BC" = "" ]
then
	echo "\nbc application must be previously installed. Try to execute next command if you are in a debian based linux:\n"
	echo "$ sudo apt-get install bc\n"
	echo "\nIf you are in a red hat based linux, you could try with:\n"
	echo "$ sudo yum install bc\n"
	exit $ST_UK
fi

if [ -n "$warn" -a -n "$crit" ]
then
    val_wcdiff
    if [ "$wcdiff" = 1 ]
    then
		echo "Please adjust your warning/critical thresholds. The warning\\
must be lower than the critical level!"
        exit $ST_UK
    fi
fi

if [ "$CONFIG" != "" ]
then
	if [ "$SERVER" != "" ]
	then
	get_data_server
	get_volume_size
	do_unit_conversion
	do_warning_critical_settings
	do_output
	do_perfdata

	if [ -n "$warn" -a -n "$crit" ]
	then
	    if [ "$percentused" -ge "$warn" -a "$percentused" -lt "$crit" ]
	    then
			echo "WARNING - ${output} | ${perfdata}"
	        exit $ST_WR
	    elif [ "$percentused" -ge "$crit" ]
	    then
		echo "CRITICAL - ${output} | ${perfdata}"
	        exit $ST_CR
	    else
		echo "OK - ${output} | ${perfdata}"
        	exit $ST_OK
    	fi
	else
		echo "OK - ${output} | ${perfdata}"
	    exit $ST_OK
	fi
	else
		echo "No server IP or hostname supplied"
		print_help
		exit $ST_UK
	fi
else
	    echo "No config file supplied"
	    print_help
	    exit $ST_UK
fi

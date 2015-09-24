#!/bin/bash


CRITICAL=25
WARNING=20
VERBOSE=0
RESULT=OK
PERFDATA=1   #graph info
VMS=0
# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

PROGNAME=`basename $0`


print_usage() {
    echo "Usage: $PROGNAME [-w <warning>] [-c <critical>] [-p | <perfdata>]"
    echo ""
}

print_help() {
    echo ""
    echo "Script to get the total number of Virtual Machines in this ESX Host"
    echo "Defaults are warning 20 and critical 25"
    print_usage
    echo ""
    echo "by Felipe Ferreira 03/2010"
    echo ""
}


# Grab the command line arguments
#default
while test -n "$1"; do
    case "$1" in
        --help)
            print_help
            exit $STATE_OK
            ;;
        -w)
            WARNING=$2
            shift
            ;;
        -c)
            CRITICAL=$2
            shift
            ;;
        -p)
           PERFDATA=$2
           shift
           ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done




#### Main Program Gets number of VMs

VMS=$(vmware-cmd -s listvms  | wc -l)


##### Compare with thresholds

if [ $VMS -ge $WARNING ]; then
     result="Warning"
     exitstatus=$STATE_WARNING
fi

if [ $VMS -ge $CRITICAL ]; then
      result="Critical"
      exitstatus=$STATE_CRITICAL
fi

if [ $VMS -le $WARNING ]; then
     result="OK"
     exitstatus=$STATE_OK
fi


if [ $PERFDATA -eq 1 ]; then
    result="$result - Total  VMs = $VMS |VMs=$VMS;${WARNING};${CRITICAL}"
fi
if [ $PERFDATA -ne 1 ]; then
    result="$result - Total  VMs = $VMS"
fi
echo $result
exit $exitstatus



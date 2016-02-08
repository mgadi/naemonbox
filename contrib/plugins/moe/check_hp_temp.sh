#!/bin/bash
APPNAME=$(basename $0)
WARNING=0

###############################
# Check binaries before start #
###############################

binaries=$(cat<<all_required_binaries
  snmpwalk
all_required_binaries)

for required_binary in $binaries; do
  which $required_binary > /dev/null
  if [ "$?" != '0' ];then
    printf "UNKNOWN: $APPNAME: No usable '$required_binary' binary in '$PATH'\n"
    exit 3
  fi
done



######################
# print Help Message #
######################

usage () {

cat<<EOU

Usage of $APPNAME
---------------------------------------------------------------------

Usable Options:
  -H fileserver
     The Hostname variable, set your hostname instead of fileserver
     (Required option)

  -C public
     The SNMP Community variable, set your SNMP read community here
     (Required option)

  -w 50
     The temperature warning level in degrees celsius
     (Required option)

  -r 60
     The temperature warning level in degrees celsius for CPU(s)

  -h
     This help message

Examples:
  $APPNAME -H fileserver -C public -w 50 -c 60

---------------------------------------------------------------------

EOU
exit 3
}



################################
# Get Options from commandline #
################################

while getopts "w:r:C:H:h" option
do
  case $option in
    C ) COMMUNITY=$OPTARG ;;
    w ) LIMIT=$OPTARG ;;
    r ) CPULIMIT=$OPTARG ;;
    H ) HOST=$OPTARG ;;
    h ) usage ;;
  esac
done



###########################################
# Exit Unknown if not all arguments given #
###########################################

if [ -z "$COMMUNITY" ] || [ -z "$LIMIT" ] || [ -z "$HOST" ] || [ -z "$CPULIMIT" ];then
 printf "UNKNOWN: No warning limit, hostname and/or community set!"
 exit 3
fi



###########################
# Main part of the script #
###########################

# Execute snmpwalk - Ouput is "Temperature"
TEMPSTATUS=$(snmpwalk -v 2c -c $COMMUNITY $HOST .1.3.6.1.4.1.232.6.2.6.8.1.3 | cut -f4 -d ' ')

if [ -z "$TEMPSTATUS" ];then
 printf "No proper SNMP response or SNMP timeout. Check host or community string\n"
 exit 3
fi

# Get amount of Sensors
AMOUNT=$(echo "$TEMPSTATUS" | wc -l)

# Exit UNKNOWN if no output
if [ $AMOUNT -eq "0" ];then
 printf "UNKNOWN: No Temperature Sensors found "
 exit 3
fi

while [ $AMOUNT -gt 0 ]; do
 CODE=$(snmpwalk -v 2c -c $COMMUNITY $HOST .1.3.6.1.4.1.232.6.2.6.8.1.3 | cut -f4 -d ' ' | awk NR==$AMOUNT)
 TEMP=$(snmpwalk -v 2c -c $COMMUNITY $HOST .1.3.6.1.4.1.232.6.2.6.8.1.4 | cut -f4 -d ' ' | awk NR==$AMOUNT)

    # Error 1
    if [ $CODE = 1 ];then
     DESCR="Unknown Location"
    fi

    # Error 2
    if [ $CODE = 2 ];then
     DESCR="Unknown Location"
    fi

    # Error 3
    if [ $CODE = 3 ];then
     DESCR="temperature systeme"
    fi

    # Error 4
    if [ $CODE = 4 ];then
     DESCR="System Board temperature"
    fi

    # Error 5
    if [ $CODE = 5 ];then
     DESCR="temperature ioBoard"
    fi

    # Error 6
    if [ $CODE = 6 ];then
     DESCR="temperature cpu"
    fi

    # Error 7
    if [ $CODE = 7 ];then
     DESCR="memory temperature"
    fi

    # Error 8
    if [ $CODE = 8 ];then
     DESCR="storage temperature"
    fi

    # Error 9
    if [ $CODE = 9 ];then
     DESCR="removable media temperature"
    fi

    # Error 10
    if [ $CODE = 10 ];then
     DESCR="power supply temperature"
    fi

    # Error 11
    if [ $CODE = 11 ];then
     DESCR="ambient temperature"
    fi

    # Error 12
    if [ $CODE = 12 ];then
     DESCR="chassis temperature"
    fi

    # Error 13
    if [ $CODE = 13 ];then
     DESCR="bridge card temperature"
    fi
if [ $CODE -ne 11 ]; then # Modification du script originel pour ne pas prendre en compte la température ambiante
if [ $CODE -ne 6 ]; then
 if [ $AMOUNT -gt 1 ];then
   if [ $TEMP -gt $LIMIT ];then
    WARNING=1
    printf "WARNING: $DESCR exceeds maximum of $LIMIT with $TEMP C, "
   else
    printf "OK: $DESCR  $TEMP C, "
   fi
 else
   if [ $TEMP -gt $LIMIT ];then
    WARNING=1
    printf "WARNING: $DESCR exceeds maximum of $LIMIT with $TEMP C"
   else
    printf "OK: $DESCR $TEMP C"
   fi
 fi
else
 if [ $AMOUNT -gt 1 ];then
   if [ $TEMP -gt $CPULIMIT ];then
    WARNING=1
    printf "WARNING: $DESCR exceeds maximum of $CPULIMIT with $TEMP C, "
   else
    printf "OK: $DESCR $TEMP C, "
   fi
 else
   if [ $TEMP -gt $CPULIMIT ];then
    WARNING=1
    printf "WARNING: $DESCR exceeds maximum of $CPULIMIT with $TEMP C"
   else
    printf "OK: $DESCR  $TEMP C"
   fi
 fi
fi
fi
 AMOUNT=$[$AMOUNT-1]
done

if [ $WARNING = 1 ];then
 exit 2
else
 exit 0
fi

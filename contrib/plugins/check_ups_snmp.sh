#!/bin/bash
hostname="myups.int"
community="public"
#defaults
warningTemp=27
criticalTemp=30
operation="batteryCharge"


function usage {
  echo ""
  echo "Usage: check_ups_snmp [-w XX -c XX] -O OperationType -H Hostname"
  echo ""
  echo -e "	OperationTypes: \n\t\tbatteryCharge - critical if different than NORMAL \n\t\ttemperature - warning and critical as per w/c parameters \n\t\toutputType - critical if different than NORMAL \n\t\talarmsCount - critical if bigger than 0"
  echo ""
  echo "	Hostname: host to check"
  echo ""
  echo "	Parameters w and c are optional and used only when checking temperatures, actual values:"
  echo "	w = $warningTemp e c = $criticalTemp"
}

function batteryCharge {
  value=$(snmpget -v1 -Oq -c$community $hostname upsBatteryStatus.0 2>/dev/null)
  if [ $? != 0 ]; then
    echo "BATTERY_CHARGE UNKNOWN: SNMP communication error"
    exit 3
  else
    set -- $value
    val=$2

    case $val in
      unknown )		echo "BATTERY_CHARGE UNKNOWN: this is what the UPS says..."
			exit 3
			;;
      batteryNormal )	echo "BATTERY_CHARGE OK"
			exit 0
			;;
      batteryLow )	echo "BATTERY_CHARGE CRITICAL: BatteryLow"
			exit 2
			;;
      batteryDepleted )	echo "BATTERY_CHARGE CRITICAL: BatteryLow"
			exit 2
			;;
      * )		echo "BATTERY_CHARGE UNKNOWN: unrecognized value - $val"
			exit 3
			;;
    esac	

  fi
}

function temperature {
  value=$(snmpget -v1 -Oq -c$community $hostname upsBatteryTemperature.0 2>/dev/null)
  if [ $? != 0 ]; then
    echo "BATTERY_TEMPERATURE UNKNOWN: SNMP communication error"
    exit 3
  else
    set -- $value
    val=$2

    if [ $(bc <<< "$val >= $criticalTemp") -eq 1 ]; then
      echo "BATTERY_TEMPERATURE CRITICAL: $val °C"
      exit 2
    elif [ $(bc <<< "$val >= $warningTemp") -eq 1  ]; then
      echo "BATTERY_TEMPERATURE WARNING: $val °C"
      exit 1
    else
      echo "BATTERY_TEMPERATURE OK: $val °C"
      exit 0
    fi
  fi
}

function outputType {
  value=$(snmpget -v1 -Oq -c$community $hostname upsOutputSource.0 2>/dev/null)
  if [ $? != 0 ]; then
    echo "OUTPUT_TYPE UNKNOWN: SNMP communication error"
    exit 3
  else
    set -- $value
    val=$2

    case $val in
      other )		echo "OUTPUT_TYPE CRITICAL: $val"
			exit 2
			;;
      none )		echo "OUTPUT_TYPE CRITICAL: $val"
			exit 2
			;;
      normal )		echo "OUTPUT_TYPE OK: $val"
			exit 0
			;;
      bypass )		echo "OUTPUT_TYPE CRITICAL: $val"
			exit 2
			;;
      battery )		echo "OUTPUT_TYPE CRITICAL: $val"
			exit 2
			;;
      booster )		echo "OUTPUT_TYPE CRITICAL: $val"
			exit 2
			;;
      reducer )		echo "OUTPUT_TYPE CRITICAL: $val"
			exit 2
			;;
      * )		echo "OUTPUT_TYPE UNKNOWN: unrecognized value - $val"
			exit 3
			;;
    esac	

  fi
}

function alarmsCount {
  value=$(snmpget -v1 -Oq -c$community $hostname upsAlarmsPresent.0 2>/dev/null)
  if [ $? != 0 ]; then
    echo "ALARMS_COUNT UNKNOWN: SNP communication error"
    exit 3
  else
    set -- $value
    val=$2
    if [ $val != 0 ]; then
      echo "ALARMS_COUNT CRITICAL: There are $2 alarms"
      exit 2
    else
      echo "ALARMS_COUNT OK"
      exit 0
    fi
  fi
}

while [ "$1" != "" ]; do
    case $1 in
        -w | --warning )        shift
                                warningTemp=$1
                                ;;
        -c | --critical )       shift
                                criticalTemp=$1
                                ;;
	-O | --operation) 	shift
				operation=$1
				;;
	-H | --hostname) 	shift
				hostname=$1
				;;
        -h | --help )           usage
                                exit 0
                                ;;
        * )                     echo "Invalid Option"
				usage
                                exit 3
    esac
    shift
done

dateTime=$(date "+%Y-%m-%d %H:%M:%S")

case $operation in
  batteryCharge )		batteryCharge
				;;
  temperature )			temperature
				;;
  outputType )			outputType
				;;
  alarmsCount )			alarmsCount
				;;
  * )				echo "Invalid Option"
				usage
				exit 3
esac


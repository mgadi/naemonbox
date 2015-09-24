#!/bin/bash
# Written By Mike Wissa
# Any Comments or Questions please e-mail to mikewissa@yahoo.com
PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION=`echo '$Revision: 1.14 $' | sed -e 's/[^0-9.]//g'`

. $PROGPATH/utils.sh

print_usage() {
	echo "Usage:"
	echo " $PROGNAME --arraystat <ip_address> <snmp_community>"
	echo " $PROGNAME --help"
	echo " $PROGNAME --version"
	echo " Created by Mike Wissa, questions or problems e-mail mikewissa@yahoo.com"
}

print_help() {
	print_revision $PROGNAME $REVISION
	echo ""
	print_usage
	echo "Checks Array status of a Dell Server. You have to have the SNMP MIBs for your hardware in the MIB repository of your linux distribution"
	echo "--arraystat <ip_address> <snmp_community>"
	echo "provides the arraystatus of the server with the specified <ip_address>, provide the <snmp_community> allowed read only or read write to that server"
	echo "--help"
	echo "prints this help screen"
	echo "--version"
	echo "Print version and license information"
	echo ""
}

check_array() {	
OLD_IFS="$IFS"
IFS=$'\n'
script_contents=($(snmpwalk -Os -v 1 -c $3 $2 arrayDiskState))  

for element in $(seq 0 $((${#script_contents[@]} - 1)))
  do                                    
IFS=$OLD_IFS
status=( ${script_contents[$element]} )
if [[ "${status[@]}" =~ 'ready|online' ]] 
then
array_status="OK"
else
echo "Problem with ${status[0]}"
array_status="NOTOK"
exit $STATE_CRITICAL
fi
done
if [[ "$array_status" == 'OK' ]] 
then
IFS=$'\n'
IFS=$OLD_IFS
echo "OK - All drives of server $2 are in a good shape"
exit $STATE_OK
else
exit $STATE_CRITICAL
fi
}

case "$1" in
--help)
                print_help
        exit $STATE_OK
        ;;
-h)
                print_help
        exit $STATE_OK
        ;;
--version)
                print_revision $PLUGIN $REVISION
        exit $STATE_OK
        ;;
-V)
                print_revision $PLUGIN $REVISION
        exit $STATE_OK
        ;;
--arraystat)
                check_array $1 $2 $3
        ;;
*)
                print_help
        exit $STATE_OK

esac


